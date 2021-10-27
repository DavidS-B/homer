# Homer
Clone this repo anywhere you want and move into the directory:
```shell
$ git clone https://github.com/DavidS-B/homer.git
$ cd homer
```

## Running this app with Elixir

### Install PostgreSQL:
https://www.postgresql.org/download/

:warning: For this project I used **PostgreSQL v12.8**
### Install Elixir:
https://elixir-lang.org/install.html

:warning: For this project I used **Elixir v1.12.3**, **Erlang/OTP 24.1.2** & **Phoenix v1.6.2**

### Build dependencies:
```
$ mix deps.get
```

### DB set up:
```
$ mix ecto.setup
```

### Start Phoenix server:
```
$ mix phx.server
```
or with the interactive shell:
```
$ iex -S mix phx.server
```

### Run tests:
```
$ mix test
```

## Access to the application

### Endpoint access to create an offer request:
```
http://localhost:4000/offer_requests
```
## Questions

1) Given than in production we can have more than 5000 offers for one offer request. What persistence strategy do you suggest for offers ? Explain why.

I suggest implementing a GenStage behaviour. It will provide back-pressure and dispatch data efficiently.

We would create a GenStage Producer that will do all the needed API requests and a GenStage Consumer that will ask to the producer how many offers it needs, setting the min_demand and max_demand accordingly.


2) We now want to deploy the app we just created on multiple servers that are connected together using distributed erlang. Which parts of the code will require an update and why ?

We will have to create and implement an Erlang-based configuration file in order to run the app on a cluster of nodes.

