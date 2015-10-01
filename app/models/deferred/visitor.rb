# This file and class exist solely to allow legacy marshalled tokens in URLs
# (sent in emails) to be loaded. These contain marshalled Deferred::Visitor
# objects, and Marshal.load raises an exception if the class does not exist.
#
# Do not add any new code here. Do not use this class anywhere.
# When this file is no longer needed, remove it.
#
module Deferred
  class Visitor < ::Visitor
  end
end
