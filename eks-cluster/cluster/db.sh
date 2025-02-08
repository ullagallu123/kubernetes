#!/bin/bash
ns=instana
helm install mongo ../instana/mongo -n $ns
helm install redis ../instana/redis -n $ns
helm install rabbit ../instana/rabbit -n $ns
helm install mysql ../instana/mysql -n $ns