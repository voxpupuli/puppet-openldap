# frozen_string_literal: true

def idempotent_apply(pp)
  apply_manifest(pp, catch_failures: true)
  apply_manifest(pp, catch_changes: true)
end

def ldapsearch(_cmd, _exit_codes = [0, 1])
  puts 'shell() not working in litmus for now'
  # shell("ldapsearch #{cmd}", acceptable_exit_codes: exit_codes, &block)
end
