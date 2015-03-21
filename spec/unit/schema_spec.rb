require_relative '../spec_helper'


require 'rspec/expectations'
require 'active_attr/matchers/have_attribute_matcher'
require 'shoulda-matchers'

describe Syncano::Schema do
  include ActiveAttr::Matchers

  let(:connection) { double("connection") }

  subject { described_class.new connection }

  before do
    expect(connection).to receive(:request).with(:get, described_class::SCHEMA_PATH) { schema }

    Syncano::Resources.instance_eval do
      constants.each do |const|
        if ![:Base, :Collection, :Space].include?(const) && const_defined?(const)
          remove_const const
        end
      end
    end
  end

  describe 'process!' do
    it 'defintes classes according to the schema' do
      expect { Syncano::Resources::Class }.to raise_error(NameError)

      subject.process!

      expect { Syncano::Resources::Class }.to_not raise_error

      expect(Syncano::Resources::Class).to have_attribute(:name)
      expect(Syncano::Resources::Class).to have_attribute(:status)
      expect(Syncano::Resources::Class).to have_attribute(:created_at)
      expect(Syncano::Resources::Class).to have_attribute(:description)
      expect(Syncano::Resources::Class).to have_attribute(:updated_at)
      expect(Syncano::Resources::Class).to have_attribute(:objects_count)
      expect(Syncano::Resources::Class).to have_attribute(:metadata)
      expect(Syncano::Resources::Class).to have_attribute(:revision)

      class_instance = Syncano::Resources::Class.new(connection, {}, { links: {} })

      expect(class_instance).to validate_presence_of(:name)
      expect(class_instance).to validate_length_of(:name).is_at_most(50)

      expect(class_instance).to respond_to(:objects)

      code_box_instance = Syncano::Resources::CodeBox.new(connection, {}, { links: {} })
      expect(code_box_instance).to validate_inclusion_of(:runtime_name).
                                             in_array(%w(nodejs ruby python))

    end

    it 'defines foreign keys attributes when attributes names collide with links' do
      subject.process!

      schedule_instance = Syncano::Resources::Schedule.new connection, {}, links: {}

      expect(schedule_instance).to respond_to(:codebox)
    end
  end

  def schema
   JSON.parse('
   [
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "state": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "new",
                    "value": 1
                  },
                  {
                    "display_name": "declined",
                    "value": 2
                  },
                  {
                    "display_name": "accepted",
                    "value": 3
                  }
                ]
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "---------",
                    "value": ""
                  },
                  {
                    "display_name": "full",
                    "value": "full"
                  },
                  {
                    "display_name": "write",
                    "value": "write"
                  },
                  {
                    "display_name": "read",
                    "value": "read"
                  }
                ]
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "instance"
                  }
                ]
              },
              "email": {
                "read_only": true,
                "max_length": 254,
                "required": true,
                "type": "email",
                "label": "email"
              }
            },
            "properties": [],
            "path": "/v1/account/invitations/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch"
            ],
            "fields": {
              "state": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "new",
                    "value": 1
                  },
                  {
                    "display_name": "declined",
                    "value": 2
                  },
                  {
                    "display_name": "accepted",
                    "value": 3
                  }
                ]
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "---------",
                    "value": ""
                  },
                  {
                    "display_name": "full",
                    "value": "full"
                  },
                  {
                    "display_name": "write",
                    "value": "write"
                  },
                  {
                    "display_name": "read",
                    "value": "read"
                  }
                ]
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "instance"
                  }
                ]
              },
              "email": {
                "read_only": true,
                "max_length": 254,
                "required": true,
                "type": "email",
                "label": "email"
              }
            },
            "properties": [
              "id"
            ],
            "path": "/v1/account/invitations/{id}/"
          }
        },
        "name": "AdminInvitation"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "first_name": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "last_name": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "email": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "role": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "full",
                    "value": "full"
                  },
                  {
                    "display_name": "write",
                    "value": "write"
                  },
                  {
                    "display_name": "read",
                    "value": "read"
                  }
                ]
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "field",
                "primary_key": true
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/admins/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "first_name": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "last_name": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "email": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "role": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "full",
                    "value": "full"
                  },
                  {
                    "display_name": "write",
                    "value": "write"
                  },
                  {
                    "display_name": "read",
                    "value": "read"
                  }
                ]
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "field",
                "primary_key": true
              }
            },
            "properties": [
              "instance_name",
              "admin_id"
            ],
            "path": "/v1/instances/{instance_name}/admins/{admin_id}/"
          }
        },
        "name": "Admin"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "api_key": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "ignore_acl": {
                "read_only": false,
                "required": false,
                "type": "boolean"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/api_keys/"
          },
          "detail": {
            "methods": [
              "get",
              "delete"
            ],
            "fields": {
              "api_key": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "ignore_acl": {
                "read_only": false,
                "required": false,
                "type": "boolean"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/api_keys/{id}/"
          }
        },
        "name": "ApiKey"
      },
      {
        "endpoints": {
          "balance": {
            "methods": [
              "get"
            ],
            "fields": {
              "value": {
                "read_only": false,
                "required": true,
                "type": "decimal"
              }
            },
            "properties": [],
            "path": "/v1/billing/balance/"
          }
        },
        "name": "BalanceView"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "status": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "name": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 50,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "objects"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "objects_count": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "metadata": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "metadata"
              },
              "revision": {
                "read_only": true,
                "required": true,
                "type": "integer",
                "label": "revision"
              },
              "schema": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "schema"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/classes/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "status": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "expected_revision": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "Expected revision"
              },
              "name": {
                "read_only": true,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 50,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "objects"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "objects_count": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "metadata": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "metadata"
              },
              "revision": {
                "read_only": true,
                "required": true,
                "type": "integer",
                "label": "revision"
              },
              "schema": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "schema"
              }
            },
            "properties": [
              "instance_name",
              "name"
            ],
            "path": "/v1/instances/{instance_name}/classes/{name}/"
          }
        },
        "name": "Class"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "codebox_id"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_id}/traces/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "codebox_id",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_id}/traces/{id}/"
          }
        },
        "name": "CodeBoxTrace"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "runtimes"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "source": {
                "read_only": false,
                "required": true,
                "type": "string",
                "label": "source"
              },
              "runtime_name": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "golang",
                    "value": "golang"
                  },
                  {
                    "display_name": "nodejs",
                    "value": "nodejs"
                  },
                  {
                    "display_name": "python",
                    "value": "python"
                  },
                  {
                    "display_name": "ruby",
                    "value": "ruby"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "runtime name"
              },
              "config": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "config"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/"
          },
          "run": {
            "methods": [
              "post"
            ],
            "fields": {
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "runtimes"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "source": {
                "read_only": false,
                "required": true,
                "type": "string",
                "label": "source"
              },
              "runtime_name": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "golang",
                    "value": "golang"
                  },
                  {
                    "display_name": "nodejs",
                    "value": "nodejs"
                  },
                  {
                    "display_name": "python",
                    "value": "python"
                  },
                  {
                    "display_name": "ruby",
                    "value": "ruby"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "runtime name"
              },
              "config": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "config"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/{id}/run/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "runtimes"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "source": {
                "read_only": false,
                "required": true,
                "type": "string",
                "label": "source"
              },
              "runtime_name": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "golang",
                    "value": "golang"
                  },
                  {
                    "display_name": "nodejs",
                    "value": "nodejs"
                  },
                  {
                    "display_name": "python",
                    "value": "python"
                  },
                  {
                    "display_name": "ruby",
                    "value": "ruby"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "runtime name"
              },
              "config": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "config"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/{id}/"
          }
        },
        "name": "CodeBox"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 32,
                "type": "string"
              },
              "percent_off": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "percent off"
              },
              "redeem_by": {
                "read_only": false,
                "required": true,
                "type": "date",
                "label": "redeem by"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "redeem"
                  }
                ]
              },
              "amount_off": {
                "read_only": false,
                "required": false,
                "type": "float",
                "label": "amount off"
              },
              "currency": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "USD",
                    "value": "usd"
                  }
                ]
              },
              "duration": {
                "read_only": false,
                "required": true,
                "type": "integer",
                "label": "duration"
              }
            },
            "properties": [],
            "path": "/v1/billing/coupons/"
          },
          "detail": {
            "methods": [
              "get",
              "delete"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 32,
                "type": "string"
              },
              "percent_off": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "percent off"
              },
              "redeem_by": {
                "read_only": false,
                "required": true,
                "type": "date",
                "label": "redeem by"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "redeem"
                  }
                ]
              },
              "amount_off": {
                "read_only": false,
                "required": false,
                "type": "float",
                "label": "amount off"
              },
              "currency": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "USD",
                    "value": "usd"
                  }
                ]
              },
              "duration": {
                "read_only": false,
                "required": true,
                "type": "integer",
                "label": "duration"
              }
            },
            "properties": [
              "name"
            ],
            "path": "/v1/billing/coupons/{name}/"
          }
        },
        "name": "Coupon"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "required": true,
                "type": "string"
              }
            },
            "properties": [],
            "path": "/v1/metrics/filters/"
          }
        },
        "name": "DimensionTypeListView"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "end": {
                "read_only": true,
                "required": true,
                "type": "date",
                "label": "end"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "start": {
                "read_only": true,
                "required": false,
                "type": "date",
                "label": "start"
              },
              "coupon": {
                "name": {
                  "read_only": false,
                  "max_length": 32,
                  "required": true,
                  "type": "string",
                  "label": "name"
                },
                "percent_off": {
                  "read_only": false,
                  "required": false,
                  "type": "integer",
                  "label": "percent off"
                },
                "redeem_by": {
                  "read_only": false,
                  "required": true,
                  "type": "date",
                  "label": "redeem by"
                },
                "links": {
                  "read_only": true,
                  "required": false,
                  "type": "links",
                  "links": [
                    {
                      "type": "detail",
                      "name": "self"
                    },
                    {
                      "type": "list",
                      "name": "redeem"
                    }
                  ],
                  "label": "Links"
                },
                "amount_off": {
                  "read_only": false,
                  "required": false,
                  "type": "float",
                  "label": "amount off"
                },
                "currency": {
                  "read_only": false,
                  "choices": [
                    {
                      "display_name": "USD",
                      "value": "usd"
                    }
                  ],
                  "required": true,
                  "type": "choice",
                  "label": "Currency"
                },
                "duration": {
                  "read_only": false,
                  "required": true,
                  "type": "integer",
                  "label": "duration"
                }
              },
              "instance": {
                "name": {
                  "read_only": false,
                  "max_length": 50,
                  "required": true,
                  "type": "string",
                  "label": "name"
                },
                "links": {
                  "read_only": true,
                  "required": false,
                  "type": "links",
                  "links": [
                    {
                      "type": "detail",
                      "name": "self"
                    },
                    {
                      "type": "list",
                      "name": "admins"
                    },
                    {
                      "type": "list",
                      "name": "classes"
                    },
                    {
                      "type": "list",
                      "name": "codeboxes"
                    },
                    {
                      "type": "list",
                      "name": "runtimes"
                    },
                    {
                      "type": "list",
                      "name": "invitations"
                    },
                    {
                      "type": "list",
                      "name": "api_keys"
                    },
                    {
                      "type": "list",
                      "name": "triggers"
                    },
                    {
                      "type": "list",
                      "name": "webhooks"
                    },
                    {
                      "type": "list",
                      "name": "schedules"
                    }
                  ],
                  "label": "Links"
                },
                "created_at": {
                  "read_only": true,
                  "required": false,
                  "type": "datetime",
                  "label": "created at"
                },
                "updated_at": {
                  "read_only": true,
                  "required": false,
                  "type": "datetime",
                  "label": "updated at"
                },
                "role": {
                  "read_only": true,
                  "required": false,
                  "type": "field",
                  "label": "Role"
                },
                "owner": {
                  "first_name": {
                    "read_only": false,
                    "max_length": 35,
                    "required": false,
                    "type": "string",
                    "label": "first name"
                  },
                  "last_name": {
                    "read_only": false,
                    "max_length": 35,
                    "required": false,
                    "type": "string",
                    "label": "last name"
                  },
                  "id": {
                    "read_only": true,
                    "required": false,
                    "type": "integer",
                    "label": "ID"
                  },
                  "email": {
                    "read_only": false,
                    "max_length": 254,
                    "required": true,
                    "type": "email",
                    "label": "email address"
                  }
                },
                "metadata": {
                  "read_only": false,
                  "required": false,
                  "type": "field",
                  "label": "metadata"
                },
                "description": {
                  "read_only": false,
                  "required": false,
                  "type": "string",
                  "label": "description"
                }
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [],
            "path": "/v1/billing/discounts/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "end": {
                "read_only": true,
                "required": true,
                "type": "date",
                "label": "end"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "start": {
                "read_only": true,
                "required": false,
                "type": "date",
                "label": "start"
              },
              "coupon": {
                "name": {
                  "read_only": false,
                  "max_length": 32,
                  "required": true,
                  "type": "string",
                  "label": "name"
                },
                "percent_off": {
                  "read_only": false,
                  "required": false,
                  "type": "integer",
                  "label": "percent off"
                },
                "redeem_by": {
                  "read_only": false,
                  "required": true,
                  "type": "date",
                  "label": "redeem by"
                },
                "links": {
                  "read_only": true,
                  "required": false,
                  "type": "links",
                  "links": [
                    {
                      "type": "detail",
                      "name": "self"
                    },
                    {
                      "type": "list",
                      "name": "redeem"
                    }
                  ],
                  "label": "Links"
                },
                "amount_off": {
                  "read_only": false,
                  "required": false,
                  "type": "float",
                  "label": "amount off"
                },
                "currency": {
                  "read_only": false,
                  "choices": [
                    {
                      "display_name": "USD",
                      "value": "usd"
                    }
                  ],
                  "required": true,
                  "type": "choice",
                  "label": "Currency"
                },
                "duration": {
                  "read_only": false,
                  "required": true,
                  "type": "integer",
                  "label": "duration"
                }
              },
              "instance": {
                "name": {
                  "read_only": false,
                  "max_length": 50,
                  "required": true,
                  "type": "string",
                  "label": "name"
                },
                "links": {
                  "read_only": true,
                  "required": false,
                  "type": "links",
                  "links": [
                    {
                      "type": "detail",
                      "name": "self"
                    },
                    {
                      "type": "list",
                      "name": "admins"
                    },
                    {
                      "type": "list",
                      "name": "classes"
                    },
                    {
                      "type": "list",
                      "name": "codeboxes"
                    },
                    {
                      "type": "list",
                      "name": "runtimes"
                    },
                    {
                      "type": "list",
                      "name": "invitations"
                    },
                    {
                      "type": "list",
                      "name": "api_keys"
                    },
                    {
                      "type": "list",
                      "name": "triggers"
                    },
                    {
                      "type": "list",
                      "name": "webhooks"
                    },
                    {
                      "type": "list",
                      "name": "schedules"
                    }
                  ],
                  "label": "Links"
                },
                "created_at": {
                  "read_only": true,
                  "required": false,
                  "type": "datetime",
                  "label": "created at"
                },
                "updated_at": {
                  "read_only": true,
                  "required": false,
                  "type": "datetime",
                  "label": "updated at"
                },
                "role": {
                  "read_only": true,
                  "required": false,
                  "type": "field",
                  "label": "Role"
                },
                "owner": {
                  "first_name": {
                    "read_only": false,
                    "max_length": 35,
                    "required": false,
                    "type": "string",
                    "label": "first name"
                  },
                  "last_name": {
                    "read_only": false,
                    "max_length": 35,
                    "required": false,
                    "type": "string",
                    "label": "last name"
                  },
                  "id": {
                    "read_only": true,
                    "required": false,
                    "type": "integer",
                    "label": "ID"
                  },
                  "email": {
                    "read_only": false,
                    "max_length": 254,
                    "required": true,
                    "type": "email",
                    "label": "email address"
                  }
                },
                "metadata": {
                  "read_only": false,
                  "required": false,
                  "type": "field",
                  "label": "metadata"
                },
                "description": {
                  "read_only": false,
                  "required": false,
                  "type": "string",
                  "label": "description"
                }
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "id"
            ],
            "path": "/v1/billing/discounts/{id}/"
          }
        },
        "name": "Discount"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {},
            "properties": [],
            "path": "/v1/billing/info/"
          }
        },
        "name": "Info"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 50,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "admins"
                  },
                  {
                    "type": "list",
                    "name": "classes"
                  },
                  {
                    "type": "list",
                    "name": "codeboxes"
                  },
                  {
                    "type": "list",
                    "name": "runtimes"
                  },
                  {
                    "type": "list",
                    "name": "invitations"
                  },
                  {
                    "type": "list",
                    "name": "api_keys"
                  },
                  {
                    "type": "list",
                    "name": "triggers"
                  },
                  {
                    "type": "list",
                    "name": "webhooks"
                  },
                  {
                    "type": "list",
                    "name": "schedules"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "owner": {
                "first_name": {
                  "read_only": false,
                  "max_length": 35,
                  "required": false,
                  "type": "string",
                  "label": "first name"
                },
                "last_name": {
                  "read_only": false,
                  "max_length": 35,
                  "required": false,
                  "type": "string",
                  "label": "last name"
                },
                "id": {
                  "read_only": true,
                  "required": false,
                  "type": "integer",
                  "label": "ID"
                },
                "email": {
                  "read_only": false,
                  "max_length": 254,
                  "required": true,
                  "type": "email",
                  "label": "email address"
                }
              },
              "metadata": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "metadata"
              },
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              }
            },
            "properties": [],
            "path": "/v1/instances/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "name": {
                "read_only": true,
                "primary_key": true,
                "required": true,
                "label": "name",
                "max_length": 50,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "admins"
                  },
                  {
                    "type": "list",
                    "name": "classes"
                  },
                  {
                    "type": "list",
                    "name": "codeboxes"
                  },
                  {
                    "type": "list",
                    "name": "runtimes"
                  },
                  {
                    "type": "list",
                    "name": "invitations"
                  },
                  {
                    "type": "list",
                    "name": "api_keys"
                  },
                  {
                    "type": "list",
                    "name": "triggers"
                  },
                  {
                    "type": "list",
                    "name": "webhooks"
                  },
                  {
                    "type": "list",
                    "name": "schedules"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "owner": {
                "first_name": {
                  "read_only": false,
                  "max_length": 35,
                  "required": false,
                  "type": "string",
                  "label": "first name"
                },
                "last_name": {
                  "read_only": false,
                  "max_length": 35,
                  "required": false,
                  "type": "string",
                  "label": "last name"
                },
                "id": {
                  "read_only": true,
                  "required": false,
                  "type": "integer",
                  "label": "ID"
                },
                "email": {
                  "read_only": false,
                  "max_length": 254,
                  "required": true,
                  "type": "email",
                  "label": "email address"
                }
              },
              "metadata": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "metadata"
              },
              "description": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "description"
              }
            },
            "properties": [
              "name"
            ],
            "path": "/v1/instances/{name}/"
          }
        },
        "name": "Instance"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "email": {
                "read_only": false,
                "max_length": 254,
                "required": true,
                "type": "email",
                "label": "email"
              },
              "state": {
                "read_only": true,
                "required": false,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "---------",
                    "value": ""
                  },
                  {
                    "display_name": "new",
                    "value": 1
                  },
                  {
                    "display_name": "declined",
                    "value": 2
                  },
                  {
                    "display_name": "accepted",
                    "value": 3
                  }
                ]
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "key": {
                "read_only": false,
                "max_length": 40,
                "required": true,
                "type": "string",
                "label": "key"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/invitations/"
          },
          "detail": {
            "methods": [
              "get",
              "delete"
            ],
            "fields": {
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "email": {
                "read_only": false,
                "max_length": 254,
                "required": true,
                "type": "email",
                "label": "email"
              },
              "state": {
                "read_only": true,
                "required": false,
                "type": "choice",
                "choices": [
                  {
                    "display_name": "---------",
                    "value": ""
                  },
                  {
                    "display_name": "new",
                    "value": 1
                  },
                  {
                    "display_name": "declined",
                    "value": 2
                  },
                  {
                    "display_name": "accepted",
                    "value": 3
                  }
                ]
              },
              "role": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "key": {
                "read_only": false,
                "max_length": 40,
                "required": true,
                "type": "string",
                "label": "key"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/invitations/{id}/"
          }
        },
        "name": "Invitation"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {},
            "properties": [],
            "path": "/v1/billing/invoices/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {},
            "properties": [
              "id"
            ],
            "path": "/v1/billing/invoices/{id}/"
          }
        },
        "name": "Invoice"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "revision": {
                "read_only": true,
                "required": true,
                "type": "integer",
                "label": "revision"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              }
            },
            "query_fields": [
              "id",
              "created_at",
              "updated_at",
              "revision"
            ],
            "order_fields": [
              "created_at",
              "updated_at",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/classes/{class_name}/objects/",
            "properties": [
              "instance_name",
              "class_name"
            ]
          },
          "detail": {
            "methods": [
              "delete",
              "post",
              "patch",
              "get"
            ],
            "fields": {
              "expected_revision": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "Expected revision"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "revision": {
                "read_only": true,
                "required": true,
                "type": "integer",
                "label": "revision"
              }
            },
            "properties": [
              "instance_name",
              "class_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/classes/{class_name}/objects/{id}/"
          }
        },
        "name": "Object"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "required": true,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              }
            },
            "properties": [],
            "path": "/v1/billing/plans/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "name": {
                "read_only": false,
                "required": true,
                "type": "string"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              }
            },
            "properties": [
              "id"
            ],
            "path": "/v1/billing/plans/{id}/"
          }
        },
        "name": "PricingPlan"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {},
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/codeboxes/runtimes/"
          }
        },
        "name": "Runtime"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "schedule_id"
            ],
            "path": "/v1/instances/{instance_name}/schedules/{schedule_id}/traces/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "schedule_id",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/schedules/{schedule_id}/traces/{id}/"
          }
        },
        "name": "ScheduleTrace"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "scheduled_next": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "scheduled next"
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "interval_sec": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "interval sec"
              },
              "crontab": {
                "read_only": false,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "crontab"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/schedules/"
          },
          "detail": {
            "methods": [
              "get",
              "delete"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "scheduled_next": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "scheduled next"
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "interval_sec": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "interval sec"
              },
              "crontab": {
                "read_only": false,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "crontab"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/schedules/{id}/"
          }
        },
        "name": "Schedule"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "pricing_plan": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "pricing plan"
              },
              "start": {
                "read_only": false,
                "required": true,
                "type": "date",
                "label": "start"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "pricing_plan"
                  }
                ]
              }
            },
            "properties": [],
            "path": "/v1/billing/subscriptions/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "pricing_plan": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "pricing plan"
              },
              "start": {
                "read_only": false,
                "required": true,
                "type": "date",
                "label": "start"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "pricing_plan"
                  }
                ]
              }
            },
            "properties": [
              "id"
            ],
            "path": "/v1/billing/subscriptions/{id}/"
          }
        },
        "name": "Subscription"
      },
      {
        "endpoints": {
          "tabular_trend": {
            "methods": [
              "get"
            ],
            "fields": {
              "end": {
                "read_only": false,
                "required": true,
                "type": "datetime"
              },
              "instance": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "Instance"
              },
              "start": {
                "read_only": false,
                "required": true,
                "type": "datetime"
              },
              "step": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": 60,
                    "value": 60
                  },
                  {
                    "display_name": 3600,
                    "value": 3600
                  },
                  {
                    "display_name": 86400,
                    "value": 86400
                  }
                ]
              },
              "group_by": {
                "read_only": false,
                "required": false,
                "type": "field"
              },
              "samples": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "browser_family": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "Browser family"
              }
            },
            "properties": [
              "indicator_name"
            ],
            "path": "/v1/metrics/trend/{indicator_name}/"
          }
        },
        "name": "TabularTrendView"
      },
      {
        "endpoints": {
          "tech_tabular_trend": {
            "methods": [
              "get"
            ],
            "fields": {
              "end": {
                "read_only": false,
                "required": true,
                "type": "integer"
              },
              "instance": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "Instance"
              },
              "start": {
                "read_only": false,
                "required": true,
                "type": "integer"
              },
              "step": {
                "read_only": false,
                "required": true,
                "type": "choice",
                "choices": [
                  {
                    "display_name": 60,
                    "value": 60
                  },
                  {
                    "display_name": 3600,
                    "value": 3600
                  },
                  {
                    "display_name": 86400,
                    "value": 86400
                  }
                ]
              },
              "group_by": {
                "read_only": false,
                "required": false,
                "type": "field"
              },
              "samples": {
                "read_only": true,
                "required": false,
                "type": "field"
              },
              "browser_family": {
                "read_only": false,
                "required": false,
                "type": "field",
                "label": "Browser family"
              }
            },
            "properties": [
              "indicator_name"
            ],
            "path": "/v1/metrics/tech/trend/{indicator_name}/"
          }
        },
        "name": "TechTabularTrendView"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "trigger_id"
            ],
            "path": "/v1/instances/{instance_name}/triggers/{trigger_id}/traces/"
          },
          "detail": {
            "methods": [
              "get"
            ],
            "fields": {
              "status": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "Pending",
                    "value": "pending"
                  },
                  {
                    "display_name": "Success",
                    "value": "success"
                  },
                  {
                    "display_name": "Failure",
                    "value": "failure"
                  },
                  {
                    "display_name": "Timeout",
                    "value": "timeout"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "status"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  }
                ]
              },
              "executed_at": {
                "read_only": false,
                "required": false,
                "type": "datetime",
                "label": "executed at"
              },
              "result": {
                "read_only": false,
                "required": false,
                "type": "string",
                "label": "result"
              },
              "duration": {
                "read_only": false,
                "required": false,
                "type": "integer",
                "label": "duration"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              }
            },
            "properties": [
              "instance_name",
              "trigger_id",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/triggers/{trigger_id}/traces/{id}/"
          }
        },
        "name": "TriggerTrace"
      },
      {
        "endpoints": {
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  },
                  {
                    "type": "detail",
                    "name": "klass"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "klass": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "class"
              },
              "signal": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "post_update",
                    "value": "post_update"
                  },
                  {
                    "display_name": "post_create",
                    "value": "post_create"
                  },
                  {
                    "display_name": "post_delete",
                    "value": "post_delete"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "signal"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/triggers/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "name": {
                "read_only": false,
                "max_length": 80,
                "required": true,
                "type": "string",
                "label": "name"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  },
                  {
                    "type": "detail",
                    "name": "klass"
                  },
                  {
                    "type": "list",
                    "name": "traces"
                  }
                ]
              },
              "created_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "created at"
              },
              "updated_at": {
                "read_only": true,
                "required": false,
                "type": "datetime",
                "label": "updated at"
              },
              "id": {
                "read_only": true,
                "required": false,
                "type": "integer",
                "primary_key": true,
                "label": "ID"
              },
              "klass": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "class"
              },
              "signal": {
                "read_only": false,
                "choices": [
                  {
                    "display_name": "post_update",
                    "value": "post_update"
                  },
                  {
                    "display_name": "post_create",
                    "value": "post_create"
                  },
                  {
                    "display_name": "post_delete",
                    "value": "post_delete"
                  }
                ],
                "required": true,
                "type": "choice",
                "label": "signal"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/triggers/{id}/"
          }
        },
        "name": "Trigger"
      },
      {
        "endpoints": {
          "run": {
            "methods": [
              "get"
            ],
            "fields": {
              "public_link": {
                "read_only": false,
                "primary_key": true,
                "required": false,
                "label": "public link",
                "max_length": 40,
                "type": "string"
              },
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "slug": {
                "read_only": false,
                "max_length": 50,
                "required": true,
                "type": "slug",
                "label": "slug"
              },
              "public": {
                "read_only": false,
                "required": false,
                "type": "boolean",
                "label": "public"
              }
            },
            "properties": [
              "instance_name",
              "public_link"
            ],
            "path": "/v1/instances/{instance_name}/webhooks/p/{public_link}/"
          }
        },
        "name": "WebhookPublicView"
      },
      {
        "endpoints": {
          "link": {
            "methods": [
              "post"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "public": {
                "read_only": false,
                "required": false,
                "type": "boolean",
                "label": "public"
              },
              "slug": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "slug",
                "max_length": 50,
                "type": "slug"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "public_link": {
                "read_only": true,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "public link"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/webhooks/{id}/reset_link/"
          },
          "run": {
            "methods": [
              "get"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "public": {
                "read_only": false,
                "required": false,
                "type": "boolean",
                "label": "public"
              },
              "slug": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "slug",
                "max_length": 50,
                "type": "slug"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "public_link": {
                "read_only": true,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "public link"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/webhooks/{id}/run/"
          },
          "list": {
            "methods": [
              "post",
              "get"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "public": {
                "read_only": false,
                "required": false,
                "type": "boolean",
                "label": "public"
              },
              "slug": {
                "read_only": false,
                "primary_key": true,
                "required": true,
                "label": "slug",
                "max_length": 50,
                "type": "slug"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "public_link": {
                "read_only": true,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "public link"
              }
            },
            "properties": [
              "instance_name"
            ],
            "path": "/v1/instances/{instance_name}/webhooks/"
          },
          "detail": {
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ],
            "fields": {
              "codebox": {
                "read_only": false,
                "required": true,
                "type": "field",
                "label": "codebox"
              },
              "public": {
                "read_only": false,
                "required": false,
                "type": "boolean",
                "label": "public"
              },
              "slug": {
                "read_only": true,
                "primary_key": true,
                "required": true,
                "label": "slug",
                "max_length": 50,
                "type": "slug"
              },
              "links": {
                "read_only": true,
                "required": false,
                "type": "links",
                "links": [
                  {
                    "type": "detail",
                    "name": "self"
                  },
                  {
                    "type": "run",
                    "name": "run"
                  },
                  {
                    "type": "detail",
                    "name": "codebox"
                  }
                ]
              },
              "public_link": {
                "read_only": true,
                "max_length": 40,
                "required": false,
                "type": "string",
                "label": "public link"
              }
            },
            "properties": [
              "instance_name",
              "id"
            ],
            "path": "/v1/instances/{instance_name}/webhooks/{id}/"
          }
        },
        "name": "Webhook"
      }
  ]  ')
  end
end
