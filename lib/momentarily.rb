require "rubygems"
require "./lib/momentarily/version.rb"
require "eventmachine"


module Momentarily
	DEBUG = true

	def Momentarily.start(loopInitializer = nil, abort = false)
		if defined?(PhusionPassenger)
			puts "Passenger thread init." if DEBUG
			PhusionPassenger.on_event(:starting_worker_process) do |forked|
				# for passenger, we need to avoid orphaned threads
				if forked && EM.reactor_running?
					EM.stop
				end
				Thread.new {
					EM.run do
						begin
							loopInitializer.call() unless loopInitializer.nil?
						rescue => ex
							puts "Momentarily reactor initializer failed with: " + ex.to_s
						end
					end
				}
				die_gracefully_on_signal
			end
		else
			# faciliates debugging
			Thread.abort_on_exception = abort
			# Thin is built on EventMachine, doesn't need another thread
			if defined?(Thin) || EM.reactor_running?
				puts "Thin init." if DEBUG
				# still do our initializer if Thin has it's own EM going already
				EM.next_tick( loopInitializer ) unless loopInitializer.nil?
			else
				# spawn a thread and start it up
				puts "Standard thread init." if DEBUG
				Thread.new {
					EM.run do
						begin
							loopInitializer.call() unless loopInitializer.nil?
						rescue => ex
							puts "Momentarily reactor initializer failed with: " + ex.to_s
						end
					end
				}
			end

		end
	end

	def Momentarily.die_gracefully_on_signal
		Signal.trap("INT")  { EM.stop }
		Signal.trap("TERM") { EM.stop }
	end
	
	def Momentarily.later
	end

	def Momentarily.next_tick
		EM.next_tick
	end

end # Momentarily
