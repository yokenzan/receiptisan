exit 1 unless ARGV.length == 2

ukes            = {}
uke             = nil
current_id      = nil

File.open(ARGV.first, 'r:Windows-31J:UTF-8') do | f |
  while line = f.gets
    if line =~ /^RE/
      ukes[current_id.intern] = uke if current_id

      uke        = []
      columns    = line.split(',')
      current_id = columns[13]
      puts current_id
    end
    uke << line if current_id
  end
end
ukes[current_id.intern] = uke

ukes.each do | key, uke |
  File.open('./result/%s_%05d.UKE' % [ARGV.last, key.to_s.to_i], 'w') { | f | uke.each { | line | f.puts line } }
end
