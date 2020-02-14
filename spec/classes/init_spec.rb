require 'spec_helper'
# rubocop:disable Metrics/BlockLength
describe 'osbaseline', type: :class do
  shared_context 'Kernel Linux' do
    it_behaves_like 'Unixy FOSS'

    it do should contain_class('logrotate') end
    it do should contain_class('puppet_agent') end
  end

  shared_context 'OS family Debian' do
    it_behaves_like 'Kernel Linux'
    it do should contain_class('apt') end
  end

  shared_context 'OS family Darwin' do
    it_behaves_like 'Unixy'
    it do should contain_class('homebrew') end
  end

  shared_context 'OS family FreeBSD' do
    it_behaves_like 'Unixy FOSS'

    it do should contain_package('shells/bash') end
    it do should contain_package('shells/bash-completion') end
    it do should contain_mount('/dev/fd') end

    it do should contain_file('/home').with_target('usr/home') end
    it do should contain_file('/usr/home').with_ensure('directory') end

    it do should contain_class('pkgng') end
    it do
      should contain_cron('freebsd-update cron').with_command(
        '/usr/sbin/freebsd-update cron'
      )
    end
  end

  shared_context 'OS family RedHat' do
    it_behaves_like 'Kernel Linux'

    it do should contain_class('epel') end
    it do should contain_class('yum') end
    it do should contain_package('epel-release') end

    it do should contain_class('selinux') end
  end

  shared_context 'OS family Windows' do
    it do should contain_class('puppet_agent') end

    context 'with puppet_agent excluded' do
      let :params do
        { classes_exclude: ['puppet_agent'] }
      end
      it do should_not contain_class('puppet_agent') end
    end
  end

  shared_context 'Unixy' do
    it do should contain_class('wget') end
  end

  shared_context 'Unixy FOSS' do
    it_behaves_like 'Unixy'
    it do should contain_class('git') end
    it do should contain_class('ntp') end
    it do should contain_class('rsync') end

    context 'with git_configs set' do
      let :params do
        {
          git_configs: {
            'http.proxy'  => { 'value' => 'http://proxy.example.com:3128/' },
            'https.proxy' => { 'value' => 'http://proxy.example.com:3128/' }
          }
        }
      end
      it do
        should contain_git__config('http.proxy').with(
          'value' => 'http://proxy.example.com:3128/', 'scope' => 'system'
        ).that_requires('Class[osbaseline::osfamily]')
      end
      it do
        should contain_git__config('https.proxy').with(
          'value' => 'http://proxy.example.com:3128/', 'scope' => 'system'
        ).that_requires('Class[osbaseline::osfamily]')
      end
    end

    context 'with rsync excluded' do
      let :params do
        { classes_exclude: ['rsync'] }
      end
      it do should_not contain_class('rsync') end
      it do should contain_class('git') end
      it do should contain_class('ntp') end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      it do is_expected.to create_class('osbaseline') end
      it do is_expected.to create_class('osbaseline::osfamily') end

      case os
      when /^centos/ then
        it do is_expected.to compile.with_all_deps end
        it_behaves_like 'OS family RedHat'
      when /^darwin/ then
        it do is_expected.to compile.with_all_deps end
        it_behaves_like 'OS family Darwin'
      when /^freebsd/ then
        it do is_expected.to compile.with_all_deps end
        it_behaves_like 'OS family FreeBSD'
      when /^windows/ then
        # Powershell has an issue with this, so we avoid
        # it do is_expected.to compile.with_all_deps end
        it_behaves_like 'OS family Windows'
      when /^ubuntu/ then
        it do is_expected.to compile.with_all_deps end
        it_behaves_like 'OS family Debian'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
