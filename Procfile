web: bundle exec puma -t 0:2 -p $PORT -e ${RACK_ENV:-production}
worker: bundle exec sidekiq -e ${RACK_ENV:-production} --concurrency 15 --timeout 8 --queue low,1 --queue default,3 --queue critical,5
