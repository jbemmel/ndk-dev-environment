name: "{{ getenv "APPNAME" }}-dev"

topology:
  defaults:
    kind: srl
    image: ghcr.io/nokia/srlinux:21.6.4

  nodes:
    srl1:
      binds:
        - "../{{ getenv "APPNAME" }}:/opt/{{ getenv "APPNAME" }}" # mount dir with agent code
        - "../logs/srl1:/var/log/srlinux" # expose srlinux logs to a dev machine
        - "../{{ getenv "APPNAME" }}.yml:/etc/opt/srlinux/appmgr/{{ getenv "APPNAME" }}.yml" # put agent config file to appmgr directory
    srl2:
      binds:
        - "../{{ getenv "APPNAME" }}:/opt/{{ getenv "APPNAME" }}" # mount dir with agent code
        - "../logs/srl2:/var/log/srlinux" # expose srlinux logs to a dev machine
        - "../{{ getenv "APPNAME" }}.yml:/etc/opt/srlinux/appmgr/{{ getenv "APPNAME" }}.yml" # put agent config file to appmgr directory
  links:
    - endpoints:
        - "srl1:e1-1"
        - "srl2:e1-1"