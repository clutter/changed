%w[
  tmp/restart.txt
].each { |path| Spring.watch(path) }
