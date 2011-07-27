Very simple tool to do deployments.

syntax

    dep -e|--environment -r|--recipe -m|--method [-c|--config] [-d|--dry] [-q|--quiet]

    -e --environment:
        Allows you to specify the environment, which can be used to write different recipes for different environments

    -r --recipe:
        The ruby file with the methods that you want to execute

    -m --method:
        The method within the recipe that you want to execute

    -c --config:
        You can specify a custom configuration file that is in a non standard location

    -d --dry:
        Dry run. Show what will be done, but do not actually execute any commands

    -q --quiet:
        By default everything is very verbose, if you wish to quiet the output you can specify this option

    -M --methods:
        Displays all the methods that can be executed with the -m switch. Must be used with -r as only the methods
        for that recipe will be displayed

    -R --revert:
        Allows you to revert to any previous release. Displays a list of all the archived releases and allows you to
        choose which to switch to

    -l --list
        Lists all of the recipes availble for your project

    -p --parameters:
        Allows you to pass a comma separated list of key=value pairs to be used in the app
        E.g. "TEST1=test1,TEST2=test2"

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

    require 'deploy'
    require 'deploy/recipes/rails_data_mapper'

    class MyDeploy < ::Deploy::Recipes::RailsDataMapper

      def do_my_tasks
        self.class.actions = [:my_task_one, :my_task_two]
        self.class.run_actions(self)
      end

      desc "my_task_one", "explation of what my task does"
      def my_task_one
        # code...
      end

      desc "my_task_two", "explation of what my task does"
      def my_task_two
        # code...
      end

    end

Then you should just be about to call dep as normal passing in my_deploy as the recipe (-r) and do_my_tasks as the method (-m)
You could also just call the tasks themselves (-m my_task_one). But the do_my_tasks method shows how you can execute a batch
of methods in one go.