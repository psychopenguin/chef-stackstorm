CHEF_REPO_PATH="#{ENV['CHEF_REPO_PATH']}"
SLACK_TOKEN="#{ENV['SLACK_TOKEN']}"
Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-6.7"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
  end
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = CHEF_REPO_PATH + "/cookbooks"
    chef.log_level = :info
    chef.json = {
      "stackstorm" => {
        "webport" => "8443",
        "chatops" => {
          "slack-token" => SLACK_TOKEN
        }
      }
    }
    chef.run_list = [
      "stackstorm"
    ]
  end
end
