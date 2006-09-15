#!/usr/bin/env ruby
# Util::Money -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

module BBMB
  module Util
    class Money
      attr_reader :credits
      include Comparable
      def initialize(amount)
        @credits = (amount.to_f * 100).round
      end
      def to_f
        @credits.to_f / 100
      end
      def to_s
        sprintf("%1.2f", to_f)
      end
      def <=>(other)
        case other
        when Money
          @credits <=> other.credits
        else
          to_f <=> other.to_f
        end
      end
    end
  end
end
