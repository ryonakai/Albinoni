def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :unknown
    end
  )
end

def File_safe_write(file_name, data, overwrite_flag = false)
  #  Comment following two lines to enable safe writing (yet experimental).
  File.write(file_name, data)
  return

  dir, base = File.split file_name
  bak_name = File.join dir, ".#{base}.bak"
  hash_name = File.join dir, ".#{base}.sha256"

  if File.exists?( hash_name) && File.exists?(file_name)
    old_orig_hash = File.read(hash_name)
    #puts old_orig_hash
    old_file = File.read(bak_name, :encoding => 'utf-8')
    old_modified_hash = Digest::SHA256.hexdigest(old_file)
    #puts old_modified_hash
  else
    overwrite_flag = true
  end

  if overwrite_flag || (old_orig_hash == old_modified_hash)
    # overwrite anyway.
    overwrite_flag = true
  else
    puts "[#{file_name}] seems to have been changed. Not overwriting."
    ##ans = gets
    #if gets == 'y'
    #  print 'Ok. overwriting.'
    #end
  end
  if overwrite_flag
    puts "[#{file_name}] Overwriting."
    new_hash = Digest::SHA256.hexdigest(data)
    if new_hash != old_orig_hash
      File.write file_name, data
      File.write bak_name, data
      File.write hash_name, new_hash
    end
  end
end
