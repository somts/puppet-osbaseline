# We may need to manage users (eg root) ahead of anything else
class osbaseline::accounts(
  Hash $accounts_groups,
  Hash $accounts_users,
  Hash $groups,
  Hash $ssh_authorized_keys,
  Hash $users,
  Hash $virtual_accounts_groups,
  Hash $virtual_accounts_users,
) {
  create_resources('user', $users)
  create_resources('group', $groups)
  create_resources('ssh_authorized_key', $ssh_authorized_keys)

  # Accounts only works on some UNIX-like systems. For details, see
  # https://forge.puppet.com/puppetlabs/accounts
  if $facts['kernel'] in ['FreeBSD', 'Linux'] {
    create_resources('accounts::group', $accounts_groups)
    create_resources('accounts::user', $accounts_users)
    create_resources('@accounts::group', $virtual_accounts_groups)
    create_resources('@accounts::user', $virtual_accounts_users)
  }

  # osbaseline::accounts may have defined some virtual users/groups
  # that we wish to realize(), here.
  $osbaseline::realize_accounts_groups.each |String $g| {
    realize(Accounts::Group[$g])
  }
  $osbaseline::realize_accounts_users.each |String $u| {
    realize(Accounts::User[$u])
  }
}
