Very simple tool to do deployments.

syntax

    dep -e|--environment -r|--recipe -m|--method [-c|--config] [-d|--dry] [-q|--quiet]


    -e --environment
Allows you to specify the environment, which can be used to write different recipes for different environments

    -m --method
The method within the recipe that you want to execute

    -c --config
You can specify a custom configuration file that is in a non standard location. They will be autoloaded if they have
the same name as the environment and are placed under deploy/configs/

    -d --dry
Dry run. Show what will be done, but do not actually execute any commands

    -q --quiet
By default everything is very verbose, if you wish to quiet the output you can specify this option

    -M --methods
Displays all the methods that can be executed with the -m switch. Must be used with -r as only the methods
for that recipe will be displayed

    -R --revert
Allows you to revert to any previous release. Displays a list of all the archived releases and allows you to
choose which to switch to

    -l --list
Lists all of the recipes availble for your project

    -p --parameters
Allows you to pass a comma separated list of key=value pairs to be used in the app
E.g. "TEST1=test1,TEST2=test2"

    - g --generate
Allows you to generate a config or recipe file for your current app
for config file you must specify the -e option to generate the file for that environment or specify
a comma separated list of key/value pairs that tell the generator the type of generated file the name and its values

      e.g. type=config,name=my_config,git_repo=git@test.com:test.git,username=test...

This will give you a config file like this under deploy/configs/my_config.rb

      set :git_repo,          "git@test.com:test.git"
      set :username,          "test"
      set :app_name,          ""
      set :remote,            ""
      set :max_num_releases,  "5"
      set :extra_ssh_options, ""
      set :remote_user,       "test"
      set :remote_group,      ""
      set :after_login,       ""


For recipe files you will need to specify the name of the recipe, the name of the recipe you want to extend
(or leave black to just extend from the base class), and then a list of methods you want generated

      e.g. type=recipe,name=test_deploy,extends=rdm,methods="meth1 meth2 meth3",appends=meth1,prepends="meth3 meth1"

This will give you a recipe like this under deploy/recipes/test_deploy.rb

      require 'deploy'
      require 'deploy/recipes/rails_data_mapper'

      class TextDeploy < ::Deploy::Recipes::RailsDataMapper

        append  :meth1
        prepend :meth3
        prepend :meth1

        desc "meth1", "" do
        end

        desc "meth2", "" do
        end

        desc "meth3", "" do
        end
      end

examples

This will execute the deploy method in the RailsDataMapper class located in the lib/deploy/recipes folder if it exists

    dep -r production -r rails_data_mapper -m deploy

This will list the methods that are available to execute from the RailsDataMapper class

    dep -r rails_data_mapper -M

This will show what will happen when the deploy method is executed in the RailsDataMapper class, but will not actually do anything

    dep -r production -r rails_data_mapper -m deploy -d

Extending a Recipe

Because you might want to use an existing recipe but just add some functality to it, here is an short example how to do it.

In your app create the directories

    deploy/recipes

Within here create a file called for example

    my_deploy.rb

within the file you will need to require deploy and the recipe you want to extend.
Then you will need to create, or override the method you want and add the method to the list of actions to be executed

    recipe :rails_data_mapper

    append  :my_task_one
    prepend :my_task_two, :my_task_one

    desc "do_my_tasks", "runs others tasks" do
      queue [:my_task_one, :my_task_two]
      queue :my_task_one
      process_queue
    end

    desc "my_task_one", "explation of what my task does" do
      # code...
    end

    desc "my_task_two", "explation of what my task does" do
      # code...
    end


Then you should just be about to call dep as normal passing in my_deploy as the recipe (-r) and do_my_tasks as the method (-m)
You could also just call the tasks themselves (-m my_task_one). But the do_my_tasks method shows how you can execute a batch
of methods in one go. You can queue an array of tasks or individual tasks

The append and prepend methods will either add the action to the front or end of the queue of actions to be executed,
or if you supply an optional second option of an action name, the action will put put in front or behind that action in the queue.

TODO
====

describe the standard recipes