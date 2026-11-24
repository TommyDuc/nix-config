default:
	@just --list

flake := justfile_directory()
# Which host in modules/hosts/ this machine is. Single source: the ./hostname file.
hostname := trim(read(justfile_directory() / "hostname"))

write-flake:
	nix run ".#write-flake"

update *inputs:
	nix flake update {{inputs}}

update-all:
	nix flake update

[arg('deploy', long, help='SSH target for a remote build')]
[arg('host', long, help='NixOS configuration name; defaults to ./hostname')]
build deploy='' host=hostname: (_check-host host)
	nh os build \
		--accept-flake-config \
		--hostname {{host}} \
		{{if deploy != '' { f"--target-host {{deploy}}" } else { '' } }} \
		{{flake}}

[arg('deploy', long, help='SSH target for a remote test')]
[arg('host', long, help='NixOS configuration name; defaults to ./hostname')]
test deploy='' host=hostname: (_check-host host)
	nh os test \
		--hostname {{host}} \
		{{if deploy != '' { f"--target-host {{deploy}}" } else { '' } }} \
		{{flake}}

[arg('deploy', long, help='SSH target for a remote switch')]
[arg('host', long, help='NixOS configuration name; defaults to ./hostname')]
switch deploy='' host=hostname: (_check-host host)
	nh os boot \
		--ask \
		--hostname {{host}} \
		{{if deploy != '' { f"--target-host {{deploy}}" } else { '' } }} \
		{{flake}}

_check-host host:
	@test -d '{{flake}}/modules/hosts/{{host}}' || (echo "Unknown host '{{host}}': no modules/hosts/{{host}}/" >&2; exit 1)

clean:
	nh clean all

# Uses age (not rage): rage's pinentry prompt times out after 30s.
generate-master-key:
	#!/usr/bin/env bash
	set -euo pipefail
	mkdir -p secrets
	umask 077
	dir=$(mktemp -d)
	trap 'rm -rf "$dir"' EXIT
	age-keygen -o "$dir/key"
	age -p -o secrets/master-key.age "$dir/key"
	echo "Add the public key above to modules/secrets/agenix.nix"
	git add -N secrets/master-key.age

# Generate the host key that agenix uses to decrypt secrets at boot.
# `dir` must match identityPaths in modules/secrets/agenix.nix.
generate-host-key dir='/etc/agenix':
	sudo mkdir -p {{dir}}
	sudo ssh-keygen -t ed25519 -N '' -C agenix -f {{dir}}/agenix_key
	@echo "Put this public key in modules/hosts/{{hostname}}/secrets.nix:"
	sudo cat {{dir}}/agenix_key.pub

edit-secret:
	agenix edit
	git add -N **/*.age
	agenix rekey -a

prepare-deploy-ssh target:
	ssh-copy-id {{target}}

prepare-deploy-kexec target:
	ssh {{target}} "(curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root) && /root/kexec/run"

# Install a host, optionally prompting for the disk-encryption passphrase.
[confirm('This may erase all configured target disks. Continue?')]
[arg('target', help='SSH destination, such as nixos@192.0.2.1')]
[arg('host', long, help='NixOS configuration name; defaults to ./hostname')]
[arg('extra-files', long, help='Directory to copy into the installed system')]
[arg('disk-encrypt-key', long, help='Prompt for the LUKS passphrase without echoing it')]
[arg('key-path', long, help='Installer path matching Disko passwordFile')]
deploy target host=hostname extra-files='' disk-encrypt-key='' key-path='/run/luks-passphrase':
	nixos-anywhere \
		--flake {{flake}}#{{host}} \
		--target-host {{target}} \
		{{if extra-files != ''  { f"--extra-files {{extra-files}}" } else { '' } }} \
		{{if disk-encrypt-key != '' { f"--disk-encryption-keys {{key-path}} {{disk-encrypt-key}}"} else { '' }}}

save-password path:
	systemd-ask-password > {{path}}

# Enroll unattended TPM unlock on this machine; preserves the recovery passphrase.
[arg('device', help='LUKS partition to enroll, not its decrypted mapper device')]
enroll-tpm device='/dev/disk/by-partlabel/system':
	sudo systemd-cryptenroll \
		--tpm2-device=auto \
		--tpm2-pcrs=4+7+12 \
		--tpm2-with-pin=no \
		--wipe-slot=tpm2 \
		'{{device}}'
