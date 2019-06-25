#!/bin/sh

rm -r public
hugo
cp now.json public/
now --target production  public/
