#
# Ronin - A Ruby platform for exploit development and security research.
#
# Copyright (c) 2006-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA  02110-1301  USA
#

require 'ronin/extensions/ip_addr'

require 'uri'
require 'net/http'

module Ronin
  module Network
    IP_URL = URI('http://checkip.dyndns.org/')

    #
    # Determines the current external IP Address.
    #
    # @return [String]
    #   The external IP Address according to {http://checkip.dyndns.org}.
    #
    def Network.ip
      IPAddr.extract(Net::HTTP.get(IP_URL)).first
    end
  end
end