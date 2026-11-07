# Ansible Vault secrets

Copy `vault.example.yml` to the ignored working file `vault.yml`, replace the placeholders, then encrypt it before using or committing:

```bash
cp secrets/vault.example.yml secrets/vault.yml
ansible-vault encrypt secrets/vault.yml
ansible-vault edit secrets/vault.yml
```

The encrypted `vault.yml` is ignored by default to prevent accidental plaintext commits. If you want it in Git, verify its first line is `$ANSIBLE_VAULT;...` and force-add it only after encryption. Never force-add a plaintext secrets file. Keep your Vault password in a password manager, not this repository. `vault.example.yml` contains placeholders only.
