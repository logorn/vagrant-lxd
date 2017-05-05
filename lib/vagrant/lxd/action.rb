require 'json'
require 'log4r'

require 'vagrant/action/builder'

module Vagrant
  module Lxd
    module Action
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Create, action_root.join("create")
      autoload :EnsureImage, action_root.join("ensure_image")
      autoload :EnsureSsh, action_root.join("ensure_ssh")
      autoload :EnsureStarted, action_root.join("ensure_started")
      autoload :Network, action_root.join("network")

      include Vagrant::Action::Builtin

      # This action boots the VM, assuming the VM is in a state that requires
      # a bootup (i.e. not saved).
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            # If the VM is NOT created yet, then do the setup steps
            if env[:result]
              b2.use HandleBox
              b2.use EnsureImage
              b2.use Network
              b2.use Create
            end
          end
          b.use action_start
          b.use EnsureSsh
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use EnsureStarted
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use SSHExec
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
