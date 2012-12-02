Very simple tool to do deployments.

syntax

    dep -e|--environment -m|--method [-c|--config] [-d|--dry] [-q|--quiet] [-M|--methods] [-R|--revert] [-l|--list] [-p|--parameters]


What the options mean

    -e | --environment
Allows you to specify the environment, which can be used to write different recipes for different environments

    -m | --method
The method within the recipe that you want to execute

    -c | --config
You can specify a custom configuration file that is in a non standard location. They will be autoloaded if they have
the same name as the environment and are placed under deploy/configs/

    -d | --dry
Dry run. Show what will be done, but do not actually execute any commands

    -q | --quiet
By default everything is very verbose, if you wish to quiet the output you can specify this option

    -M | --methods
Displays all the methods that can be executed with the -m switch.

    -l | --list
Lists all of the recipes availble for your project

    -p | --parameters
Allows you to pass a comma separated list of key=value pairs to be used in the app
E.g. "TEST1=test1,TEST2=test2"

examples

This will execute the "deploy" method in the recipe class speified within the recipe file under deploy/recipes/production.rb

    dep -e production -m deploy

This will list the methods that are available to execute from recipe class speified within the recipe file under deploy/recipes/development.rb

    dep -e development -M

This will show what will happen when the deploy method is executed, but will not actually do anything

    dep -e production -m deploy -d