# Conf file

```
docker-compose run --rm neo4j dump-config
```

as seen here.  Note that you arent doing -up.

https://jango.si/post/running-neo4j-docker-container/

This command dumps the initial config file so that we can tweak it.

However, this appears to choke the startup.

We can set all config options via the docker file, and to check the settings for heap

```
CALL dbms.listConfig("heap")
```

For setting of variables:

```
https://neo4j.com/docs/operations-manual/current/docker/configuration/#docker-environment-variables
```


