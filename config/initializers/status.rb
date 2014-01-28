ACTIVE = 'active'
QUEUED = 'queued'
STARTED = 'started'
DELAYED = 'delayed'
COMPLETED = 'completed'
DELETED = 'deleted'
SYSTEM = 'system'

STATUS = [ACTIVE, QUEUED, STARTED, DELAYED, COMPLETED, DELETED, SYSTEM].map!(&:freeze).freeze
