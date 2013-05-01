# Imege
## Introduction
Imege provides tools which allow you to create your own image hosting site with ease.

## Usage
### Before you start
Please make sure you have Ruby 1.9 compatiable interpreter installed. You also need ``bundler`` gem, which can be installed by ``gem i bundler``, to run ``bundle install`` command which ensures you have the right environment to execute the program.

### Client
``cli.rb [FILES...]``

A command-line interface client is used to upload your images from local to remote server. You must first modify ``IMEGE_SERVER_URL`` in the script ``cli.rb`` before execution. After that, you can start the program by ``ruby cli.rb`` or ``./cli.rb``. Latter requires execute permission of ``cli.rb`` which can be granted by ``chmod +x cli.rb``.

If you haven't run the program before, it would first ask you to register a new account. Encrypted account and password will be store in your home directory as ``.imege``. You can upload your images right after registration if you have already pass image names as arguments.