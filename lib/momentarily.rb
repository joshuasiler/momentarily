$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "momentarily/version.rb"
require "eventmachine"
require 'timeout'

# designed for rails
require 'active_record'
require 'active_support/core_ext/module'

module Momentarily
	mattr_accessor :timeout, :debug
	@@timeout = 60
	@@debug = false

	def Momentarily.start
		# faciliates debugging
		Thread.abort_on_exception = @@debug
		if defined?(PhusionPassenger)
			puts "Momentarily: Passenger thread init." if @@debug
			PhusionPassenger.on_event(:starting_worker_process) do |forked|
				# for passenger, we need to avoid orphaned threads
				if forked && EM.reactor_running?
					EM.stop
				end
				Thread.new {
					EM.run
				}
				die_gracefully_on_signal
			end
		# if Thin is defined, but in console mode, Thin probably isn't running
		elsif (!EM.reactor_running? && defined?(Thin).nil?) || !defined?(Rails::Console).nil?
			# spawn a thread and start it up
			puts "Momentarily: Standard thread init." if @@debug
			Thread.new {
				EM.run
			}
		else
			# Thin is built on EventMachine, doesn't need another thread
			puts "Momentarily: Reactor already running or detected Thin." if @@debug
		end

	end

	def Momentarily.die_gracefully_on_signal
		Signal.trap("INT")  { EM.stop }
		Signal.trap("TERM") { EM.stop }
	end
	
	def Momentarily.later(work = nil, callback = nil, &block)
		if Rails.env.test?
			(work || block).call
			callback.call unless callback.blank?
		else
			EM.defer( self.railsify(( work || block )), self.railsify(callback) )
		end
	end

	def Momentarily.next_tick(work = nil, &block)
		EM.next_tick( ( work || block ) ) 
	end

	def Momentarily.defer(work = nil, callback = nil, &block)
		EM.defer( ( work || block ), callback)
	end

	def Momentarily.reactor_running?
		EM.reactor_running?
	end

private 
	def Momentarily.railsify(work)
	    unless work.nil?
			Proc.new {
				# checks out connection for use in this thread
				ActiveRecord::Base.connection_pool.with_connection do
					begin
						# make sure it doesn't hang
						Timeout::timeout(@@timeout) { work.call() unless work.nil? }
					rescue => e
						puts "Momentarily: Thread failed with: " + e.to_s if @@debug
					rescue TimeoutError => e
						puts "Momentarily: Thread timeout." if @@debug
					end
				end }
		end
	end

end # Momentarily
