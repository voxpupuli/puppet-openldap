def ldapsearch(cmd, exit_codes = [0,1], &block)
  shell("ldapsearch #{cmd}", :acceptable_exit_codes => exit_codes, &block)
end
