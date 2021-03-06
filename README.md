# Collect data from São Paulo city

This repository contains a set of scripts that collect some data about São Paulo
city for future analysis. We use mongodb to store our date since we will collect
a huge amount of data and in some point we will need to scale this.

## Install dependencies

* ruby and bundler: ```$ apt install ruby bunler -qy```
* mongodb: ```$ apt install mongodb -qy```
* scripts' dependencies: ```$ bundle install --path vendor/```

If you have any problem during the scripts' dependencies installation, probably
your issue will be around the nokogiri's build dependencies. So install them too:

```$ apt install libxml2 zlib1g-dev libpq-dev```

## Configuration

* You need to create a database in your mongodb instace
	- Login in mongodb admin shell: ```$ mongo admin```
  - Create/use your database: ```> use sp```

If you use another name (not 'sp') in your database or your mongodb instance do
not run locally you need to set these configuration in seetings.yml file.

## Collect data

* Weather: ```$ bundle exec ruby weather.rb```
  - The weather collection is based on neighborhood file, if you want to add or
    remove some neighborhood you should edit this file and everything will work
    well
* Air quality: ```$ bundle exec ruby air_quality.rb```
* Citybike: ```$ bundle exec ruby citybik.rb```

If you want to run scripts from another directory you should execute something
like these:

```$ BUNDLE_GEMFILE=<path-to-project>/Gemfile bundle exec ruby <path-to-project>/weather.rb <path-to-project>/```
```$ BUNDLE_GEMFILE=<path-to-project>/Gemfile bundle exec ruby <path-to-project>/air_quality.rb <path-to-project>/```
```$ BUNDLE_GEMFILE=<path-to-project>/Gemfile bundle exec ruby <path-to-project>/citybik.rb <path-to-project>/```
```$ BUNDLE_GEMFILE=<path-to-project>/Gemfile bundle exec ruby <path-to-project>/olho_vivo.rb <path-to-project>/```

## InterSCity publishing

To publish script's data in InterSCity platform, just:

1. Configures `interscity_config.sh` with your configuration (such as the ResourceAdaptor host)
2. Source `interscity_config.sh` file:
```
source interscity_config.sh
```
3. Run scripts
