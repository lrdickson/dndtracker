
# DND Tracker

A tool to track DND 5E campaigns

Also a template for making websites with Nim

## Building

```
nim r build.nim
```

## Usage

Running the output binary at bin/dndtracker will start an http server at localhost:5000.
It will create a sqlite database called dnd.db if none exists in the working directory at the time of the app is started.

The default login credentials are username admin, password admin.
