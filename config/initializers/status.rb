ACTIVE = 'active'
HIDDEN = 'hidden'
DELETED = 'deleted'
SYSTEM = 'system'

STATUS = [ACTIVE, HIDDEN, DELETED, SYSTEM].map!(&:freeze).freeze
