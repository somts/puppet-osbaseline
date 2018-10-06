# We may need to manage users (eg root) ahead of anything else
class osbaseline::users(
  Hash $accounts_users,
  Hash $users,
  Hash $groups,
  Hash $ssh_authorized_keys,
) {
  create_resources('user',$users)
  create_resources('group',$groups)
  create_resources('ssh_authorized_key',$ssh_authorized_keys)

  # Accounts only works on Linux. For details, see
  # https://forge.puppet.com/puppetlabs/accounts
  if $::kernel == 'Linux' {
    create_resources('accounts::users',$accounts_users)
  }
}
