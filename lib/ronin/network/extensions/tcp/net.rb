#
# Copyright (c) 2006-2011 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Support.
#
# Ronin Support is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin Support is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ronin Support.  If not, see <http://www.gnu.org/licenses/>.
#

require 'socket'

module Net
  #
  # Creates a new TCPSocket object connected to a given host and port.
  #
  # @param [String] host
  #   The host to connect to.
  #
  # @param [Integer] port
  #   The port to connect to.
  #
  # @param [String] local_host (nil)
  #   The local host to bind to.
  #
  # @param [Integer] local_port (nil)
  #   The local port to bind to.
  #
  # @yield [socket]
  #   If a block is given, it will be passed the newly created socket.
  #
  # @yieldparam [TCPsocket] socket
  #   The newly created TCPSocket object.
  #
  # @return [TCPSocket]
  #   The newly created TCPSocket object.
  #
  # @example
  #   Net.tcp_connect('www.hackety.org',80) # => TCPSocket
  #
  # @example
  #   Net.tcp_connect('www.wired.com',80) do |sock|
  #     sock.write("GET /\n\n")
  #     puts sock.readlines
  #     sock.close
  #   end
  #
  # @api public
  #
  def Net.tcp_connect(host,port,local_host=nil,local_port=nil)
    host = host.to_s
    local_host = if local_host
                   local_host.to_s
                 end

    sock = TCPSocket.new(host,port,local_host,local_port)

    yield sock if block_given?
    return sock
  end

  #
  # Creates a new TCPSocket object, connected to a given host and port.
  # The given data will then be written to the newly created TCPSocket.
  #
  # @param [String] data
  #   The data to send through the connection.
  #
  # @param [String] host
  #   The host to connect to.
  #
  # @param [Integer] port
  #   The port to connect to.
  #
  # @param [String] local_host (nil)
  #   The local host to bind to.
  #
  # @param [Integer] local_port (nil)
  #   The local port to bind to.
  #
  # @yield [socket]
  #   If a block is given, it will be passed the newly created socket.
  #
  # @yieldparam [TCPsocket] socket
  #   The newly created TCPSocket object.
  #
  # @api public
  #
  def Net.tcp_connect_and_send(data,host,port,local_host=nil,local_port=nil)
    sock = Net.tcp_connect(host,port,local_host,local_port)
    sock.write(data)

    yield sock if block_given?
    return sock
  end

  #
  # Creates a new temporary TCPSocket object, connected to the given host
  # and port.
  #
  # @param [String] host
  #   The host to connect to.
  #
  # @param [Integer] port
  #   The port to connect to.
  #
  # @param [String] local_host (nil)
  #   The local host to bind to.
  #
  # @param [Integer] local_port (nil)
  #   The local port to bind to.
  #
  # @yield [socket]
  #   If a block is given, it will be passed the newly created socket.
  #   After the block has returned, the socket will then be closed.
  #
  # @yieldparam [TCPsocket] socket
  #   The newly created TCPSocket object.
  #
  # @return [nil]
  #
  # @api public
  #
  def Net.tcp_session(host,port,local_host=nil,local_port=nil)
    sock = Net.tcp_connect(host,port,local_host,local_port)

    yield sock if block_given?

    sock.close
    return nil
  end

  #
  # Reads the banner from the service running on the given host and port.
  #
  # @param [String] host
  #   The host to connect to.
  #
  # @param [Integer] port
  #   The port to connect to.
  #
  # @param [String] local_host (nil)
  #   The local host to bind to.
  #
  # @param [Integer] local_port (nil)
  #   The local port to bind to.
  #
  # @yield [banner]
  #   If a block is given, it will be passed the grabbed banner.
  #
  # @yieldparam [String] banner
  #   The grabbed banner.
  #
  # @return [String]
  #   The grabbed banner.
  #
  # @example
  #   Net.tcp_banner('pop.gmail.com',25)
  #   # => "220 mx.google.com ESMTP c20sm3096959rvf.1"
  #
  # @api public
  #
  def Net.tcp_banner(host,port,local_host=nil,local_port=nil)
    banner = nil

    Net.tcp_session(host,port,local_host,local_port) do |sock|
      banner = sock.readline.strip
    end

    yield banner if block_given?
    return banner
  end

  #
  # Connects to a specified host and port, sends the given data and then
  # closes the connection.
  #
  # @param [String] data
  #   The data to send through the connection.
  #
  # @param [String] host
  #   The host to connect to.
  #
  # @param [Integer] port
  #   The port to connect to.
  #
  # @param [String] local_host (nil)
  #   The local host to bind to.
  #
  # @param [Integer] local_port (nil)
  #   The local port to bind to.
  #
  # @return [true]
  #   The data was successfully sent.
  #
  # @example
  #   buffer = "GET /" + ('A' * 4096) + "\n\r"
  #   Net.tcp_send(buffer,'victim.com',80)
  #   # => true
  #
  # @api public
  #
  def Net.tcp_send(data,host,port,local_host=nil,local_port=nil)
    Net.tcp_session(host,port,local_host,local_port) do |sock|
      sock.write(data)
    end

    return true
  end

  #
  # Creates a new TCPServer listening on a given host and port.
  #
  # @param [Integer] port
  #   The local port to listen on.
  #
  # @param [String] host ('0.0.0.0')
  #   The host to bind to.
  #
  # @return [TCPServer]
  #   The new TCP server.
  #
  # @example
  #   Net.tcp_server(1337)
  #
  # @api public
  #
  def Net.tcp_server(port,host='0.0.0.0')
    host = host.to_s

    server = TCPServer.new(host,port)
    server.listen(3)

    yield server if block_given?
    return server
  end

  #
  # Creates a new temporary TCPServer listening on a host and port.
  #
  # @param [Integer] port
  #   The local port to bind to.
  #
  # @param [String] host ('0.0.0.0')
  #   The host to bind to.
  #
  # @yield [server]
  #   The block which will be called after the server has been created.
  #   After the block has finished, the server will be closed.
  #
  # @yieldparam [TCPServer] server
  #   The newly created TCP server.
  #
  # @return [nil]
  #
  # @example
  #   Net.tcp_server_session(1337) do |server|
  #     client1 = server.accept
  #     client2 = server.accept
  #
  #     client2.write(server.read_line)
  #
  #     client1.close
  #     client2.close
  #   end
  #
  # @api public
  #
  def Net.tcp_server_session(port,host='0.0.0.0',&block)
    server = Net.tcp_server(port,host,&block)
    server.close()
    return nil
  end

  #
  # Creates a new TCPServer listening on a given host and port,
  # accepts only one client and then stops listening.
  #
  # @param [Integer] port
  #   After the block has finished, the client and the server will be
  #   closed.
  #
  # @yieldparam [TCPSocket] client
  #   The newly connected client.
  #
  # @return [nil]
  #
  # @example
  #   Net.tcp_single_server(1337) do |client|
  #     client.puts 'lol'
  #   end
  #
  # @api public
  #
  def Net.tcp_single_server(port,host='0.0.0.0')
    host = host.to_s

    server = TCPServer.new(host,port)
    server.listen(1)

    client = server.accept

    yield client if block_given?

    client.close
    server.close
    return nil
  end
end
