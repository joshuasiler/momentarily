require 'test/unit'
require './lib/momentarily.rb'

ActiveRecord::Base.establish_connection(YAML::load(File.read(File.dirname(__FILE__) + '/../config/database.yml')))

class TestMomentarily < Test::Unit::TestCase
	def setup
	    if !ActiveRecord::Base.connection.table_exists?('momentarily_test')
			puts "Creating test table..."
			AddEntitiesTable.create
		end
		Momentarily.debug = false
		if !Momentarily.reactor_running?
			Momentarily.start
		end
	end

	def test_instantiation
		assert(EM.reactor_running?)
	end

	def test_later
		a = 1
		Momentarily.later( Proc.new { a = 2 } )
		sleep(0.5)
		assert(a == 2)

		Momentarily.later( Proc.new { asdfputs "I am a bad proc" } )
		assert(EM.reactor_running?)

		a = 1
		Momentarily.timeout = 1
		Momentarily.later( Proc.new { 
			sleep(2)
			a = 2	 } )
		sleep(3)
		assert(a == 1)

	end

	def test_later_blocks
		a = 1
		Momentarily.later { a = 2 }
		sleep(0.5)
		assert(a == 2)

		Momentarily.later { asdfputs "I am a bad proc" } 
		assert(EM.reactor_running?)

		a = 1
		Momentarily.timeout = 1
		Momentarily.later { 
			sleep(2)
			a = 2	 } 
		sleep(3)
		assert(a == 1)

	end

	def test_next_tick
		a = 1
		Momentarily.next_tick( Proc.new { a = 2 })
		sleep(0.5)
		assert(a == 2)
		Momentarily.next_tick { a = 3 }
		sleep(0.5)
		assert(a == 3)
	end

	def simulate_thin()
		require 'thin'
		Thread.new { EM.run }
	end
end

  class AddEntitiesTable < ActiveRecord::Migration
		# up and down functions call broken code in Rail3 migrations gem, called it 'create'

    def self.create
      create_table "momentarily_test", :force => true do |t|
				t.string   "key",        :limit => 512, :null => false
				t.string     "value"
				t.datetime "created_at"
				t.datetime "updated_at"
      end

      add_index "momentarily_test", ["key"], :name => "key"
    end

  end