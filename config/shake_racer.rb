config['channel'] = Router.new

config['registry'] = Registry.new(self)

config['registry'].teams << Team.new(self, 'Team1') << Team.new(self, 'Team2')
config['registry'].matches << Match.new(self, 'Team1', 'Team2') << Match.new(self, 'Team2', 'Team1')
config['registry'].start_next_match
