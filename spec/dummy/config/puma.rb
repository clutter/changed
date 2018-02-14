workers Integer(ENV['PUMA_WORKERS'] || 0)
threads Integer(ENV['PUMA_MIN_THREADS'] || 4), Integer(ENV['PUMA_MAX_THREADS'] || 4)
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }
