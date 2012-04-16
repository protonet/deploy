Very simple tool to do deployments.

syntax

    dep -e|--environment -m|--method [-c|--config] [-d|--dry] [-q|--quiet] [-M|--methods] [-R|--revert] [-l|--list] [-p|--parameters]


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

examples

This will execute the "deploy" method in the recipe class speified within the recipe file under deploy/recipe/production.rb

    dep -e production -m deploy

This will list the methods that are available to execute from recipe class speified within the recipe file under deploy/recipe/development.rb

    dep -e development -M

This will show what will happen when the deploy method is executed, but will not actually do anything

    dep -e production -m deploy -d

Extending a Recipe

Because you might want to use an existing recipe but just add some functality to it, here is an short example how to do it.

In your app create the directories

    deploy/recipes

Within here create a file for the environment

    production.rb

within the file you will need to specify the recipe you want to extend.
Then you will need to create, or override the method you want and add the method to the list of actions to be executed

    recipe :rails_data_mapper

    append  :my_task_one
    prepend :my_task_two, :my_task_one


    # The true parameter marks the method as being one that is listed with the -M option
    # And also tells people that this is a method that you want to be public, and you don't
    # really want other not marked as public being used be themselves
    desc "do_my_tasks", "runs others tasks", true do
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


Then you should just be able to call dep as normal passing in do_my_tasks as the method (-m)
You could also just call the tasks themselves (-m my_task_one). But the do_my_tasks method shows how you can execute a batch
of methods in one go. You can queue an array of tasks or individual tasks

The append and prepend methods will either add the action to the front or end of the queue of actions to be executed,
or if you supply an optional second option of an action name, the action will put put in front or behind that action in the queue.

TODO
====

describe the standard recipes