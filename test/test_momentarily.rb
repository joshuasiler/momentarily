require 'test/unit'
require './lib/momentarily/version.rb'
require './lib/momentarily.rb'

# ActiveRecord::Base.establish_connection(YAML::load(File.read(File.dirname(__FILE__) + '/../config/database.yml')))

class TestMomentarily < Test::Unit::TestCase
	
  def teardown
  	Object.send(:remove_const, :Thin) if defined?(Thin)
	EM.stop if EM.reactor_running?
	sleep(0.5)
	assert(!EM.reactor_running?)
  end
  
  def test_instantiation
	Momentarily.start()
	assert(EM.reactor_running?)
  end

  def test_instantiation_good_proc
  	a = 1
	Momentarily.start( Proc.new { a = 2 } )
	sleep(0.5)
	assert(EM.reactor_running?)
	assert(a == 2)
  end

   def test_instantiation_bad_proc
   	# this should be a bad statement that produces an exception, but doesn't stop the reactor
	Momentarily.start( Proc.new { asdfputs "I am a bad proc"} )
	assert(EM.reactor_running?)
  end

   def test_instantiation_thin
   	simulate_thin()
	Momentarily.start()
	assert(EM.reactor_running?)
  end

  def test_instantiation_good_proc_thin
  	simulate_thin()
  	a = 1
	Momentarily.start( Proc.new { a = 2 } )
	sleep(0.5)
	assert(EM.reactor_running?)
	assert(a == 2)
  end

   def test_instantiation_bad_proc_thin
   	simulate_thin()
	Momentarily.start( Proc.new { asdfputs "I am a bad proc"} )
	assert(EM.reactor_running?)
  end

  def simulate_thin()
  	require 'thin'
  	Thread.new { EM.run }
  end
end