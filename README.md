gandimail
=========

A script to create, delete, and list Gandi.net forwarding addresses


###Setup

You will need to obtain your 24-character API key from Gandi. Set it as the environment variable `GANDI_API_KEY`

To set it temporarily for the current terminal session:
```
$ EXPORT GANDI_API_KEY="your 24-char API key"
```

###Usage

```
Usage: gandimail [options]
    -v, --version                    show Gandi API version
    -c, --create 'FROM TO@test.com'  create a new forwarding address
    -d, --delete FROM                delete an existing forwarding address
    -l, --list                       list all existing forwards
    -f, --fqdn FQDN                  specify the domain to administrate
    -h, --help                       show this message
```

###Examples

**List all forwarding address associated with domain test.com**
```
gandimail -l -f test.com
```

**Create forwarding address me@test.com to forward to me@gmail.com**
```
gandimail -c "me me@gmail.com" -f test.com
```

**Delete existing forwarding address me@test.com**
```
gandimail -d me -f test.com
```


**Note**: I have a special case hard coded in for my personal use. If `-f FQDN` isn't specified, this script will try to use `isaacdontjelindell.com` as the domain. Obviously, this won't work for you. Please always specify `-f yourdomain.com` to manage your own domain.


###Contributing

If you do something with this, fork it and send me a pull request. (Or don't. It's up to you.)

###License 

MIT
