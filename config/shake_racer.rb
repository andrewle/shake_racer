config['channel'] = EM::Channel.new

config['registry'] = Registry.new(logger)

config['registry'].teams << Team.new(logger, 'Team1') << Team.new(logger, 'Team2')
config['registry'].matches << Match.new(logger, 'Team1', 'Team2') << Match.new(logger, 'Team2', 'Team1')
config['registry'].start_next_match
