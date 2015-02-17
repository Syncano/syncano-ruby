require_relative '../spec_helper'


require 'rspec/expectations'
require 'active_attr/matchers/have_attribute_matcher'

describe Syncano::Schema do
  include ActiveAttr::Matchers

  let(:connection) { double("connection") }

  subject { described_class.new connection }

  before do
    expect(connection).to receive(:request).with(:get, described_class::SCHEMA_PATH) { schema }
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

      class_instance = Syncano::Resources::Class.new(connection, { links: {} })
      expect(class_instance).to respond_to(:objects)
    end
  end


  def schema
   JSON.parse('
   [
      {
        "endpoints": {
          "account": {
            "path": "/v1/account/",
            "properties": [],
            "methods": [
              "get",
              "put",
              "patch"
            ]
          }
        },
        "name": "AccountView",
        "properties": {
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
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/account/invitations/",
            "properties": [],
            "methods": [
              "get"
            ]
          },
          "detail": {
            "path": "/v1/account/invitations/{id}/",
            "properties": [
              "id"
            ],
            "methods": [
              "put",
              "get",
              "patch"
            ]
          }
        },
        "name": "AdminInvitation",
        "properties": {
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
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/admins/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/admins/{admin_id}/",
            "properties": [
              "instance_name",
              "admin_id"
            ],
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ]
          }
        },
        "name": "Admin",
        "properties": {
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
            "type": "field"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/api_keys/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/api_keys/{id}/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "get",
              "delete"
            ]
          }
        },
        "name": "ApiKey",
        "properties": {
          "api_key": {
            "read_only": true,
            "required": false,
            "type": "field"
          },
          "id": {
            "read_only": true,
            "required": false,
            "type": "integer",
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
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/billing/balance/",
            "properties": [],
            "methods": [
              "get"
            ]
          }
        },
        "name": "Balance",
        "properties": {}
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/classes/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/classes/{name}/",
            "properties": [
              "instance_name",
              "name"
            ],
            "methods": [
              "delete",
              "post",
              "patch",
              "get"
            ]
          }
        },
        "name": "Class",
        "properties": {
          "status": {
            "read_only": true,
            "required": false,
            "type": "field"
          },
          "name": {
            "read_only": false,
            "max_length": 64,
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
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_id}/schedules/",
            "properties": [
              "instance_name",
              "codebox_id"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_id}/schedules/{id}/",
            "properties": [
              "instance_name",
              "codebox_id",
              "id"
            ],
            "methods": [
              "get",
              "delete"
            ]
          }
        },
        "name": "CodeBoxSchedule",
        "properties": {
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
          "payload": {
            "read_only": false,
            "required": false,
            "type": "string"
          },
          "id": {
            "read_only": true,
            "required": false,
            "type": "integer",
            "label": "ID"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_schedule__codebox_id}/schedules/{codebox_schedule_id}/traces/",
            "properties": [
              "instance_name",
              "codebox_schedule__codebox_id",
              "codebox_schedule_id"
            ],
            "methods": [
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/codeboxes/{codebox_schedule__codebox_id}/schedules/{codebox_schedule_id}/traces/{id}/",
            "properties": [
              "instance_name",
              "codebox_schedule__codebox_id",
              "codebox_schedule_id",
              "id"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "CodeBoxTrace",
        "properties": {
          "status": {
            "read_only": false,
            "choices": [
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
            "required": true,
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
            "required": true,
            "type": "integer",
            "label": "duration"
          },
          "id": {
            "read_only": true,
            "required": false,
            "type": "integer",
            "label": "ID"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/codeboxes/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/codeboxes/{id}/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ]
          }
        },
        "name": "CodeBox",
        "properties": {
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
                "name": "schedules"
              },
              {
                "type": "list",
                "name": "runtimes"
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
            "label": "ID"
          },
          "name": {
            "read_only": false,
            "max_length": 80,
            "required": true,
            "type": "string",
            "label": "name"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/billing/coupons/",
            "properties": [],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/billing/coupons/{name}/",
            "properties": [
              "name"
            ],
            "methods": [
              "get",
              "delete"
            ]
          }
        },
        "name": "Coupon",
        "properties": {
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
        }
      },
      {
        "endpoints": {
          "filter_list": {
            "path": "/v1/metrics/filters/",
            "properties": [],
            "methods": [
              "get"
            ]
          }
        },
        "name": "DimensionTypeListView",
        "properties": {
          "name": {
            "read_only": false,
            "required": true,
            "type": "string"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/billing/discounts/",
            "properties": [],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/billing/discounts/{id}/",
            "properties": [
              "id"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "Discount",
        "properties": {
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
          "instance": {
            "name": {
              "read_only": false,
              "max_length": 64,
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
                  "name": "codebox_runtimes"
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
          "id": {
            "read_only": true,
            "required": false,
            "type": "integer",
            "label": "ID"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/billing/info/",
            "properties": [],
            "methods": [
              "get"
            ]
          }
        },
        "name": "Info",
        "properties": {}
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/",
            "properties": [],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{name}/",
            "properties": [
              "name"
            ],
            "methods": [
              "delete",
              "post",
              "patch",
              "get"
            ]
          }
        },
        "name": "Instance",
        "properties": {
          "name": {
            "read_only": false,
            "max_length": 64,
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
                "name": "codebox_runtimes"
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
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/invitations/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/invitations/{id}/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "get",
              "delete"
            ]
          }
        },
        "name": "Invitation",
        "properties": {
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
            "label": "ID"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/billing/invoices/",
            "properties": [],
            "methods": [
              "get"
            ]
          },
          "detail": {
            "path": "/v1/billing/invoices/{id}/",
            "properties": [
              "id"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "Invoice",
        "properties": {}
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/classes/{class_name}/objects/",
            "properties": [
              "instance_name",
              "class_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/classes/{class_name}/objects/{id}/",
            "properties": [
              "instance_name",
              "class_name",
              "id"
            ],
            "methods": [
              "delete",
              "post",
              "patch",
              "get"
            ]
          }
        },
        "name": "Object",
        "properties": {
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
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/codeboxes/runtimes/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "Runtime",
        "properties": {}
      },
      {
        "endpoints": {
          "tabular_trend": {
            "path": "/v1/metrics/trend/{indicator_name}/",
            "properties": [
              "indicator_name"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "TabularTrendView",
        "properties": {
          "end": {
            "read_only": false,
            "required": true,
            "type": "datetime"
          },
          "instance": {
            "read_only": false,
            "required": false,
            "type": "field"
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
            "type": "field"
          }
        }
      },
      {
        "endpoints": {
          "tech_tabular_trend": {
            "path": "/v1/metrics/tech/trend/{indicator_name}/",
            "properties": [
              "indicator_name"
            ],
            "methods": [
              "get"
            ]
          }
        },
        "name": "TechTabularTrendView",
        "properties": {
          "end": {
            "read_only": false,
            "required": true,
            "type": "integer"
          },
          "instance": {
            "read_only": false,
            "required": false,
            "type": "field"
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
            "type": "field"
          }
        }
      },
      {
        "endpoints": {
          "list": {
            "path": "/v1/instances/{instance_name}/triggers/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/triggers/{id}/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ]
          }
        },
        "name": "Trigger",
        "properties": {
          "codebox": {
            "read_only": false,
            "required": true,
            "type": "field",
            "label": "codebox"
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
        }
      },
      {
        "endpoints": {
          "run": {
            "path": "/v1/instances/{instance_name}/webhooks/{id}/run/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "get"
            ]
          },
          "list": {
            "path": "/v1/instances/{instance_name}/webhooks/",
            "properties": [
              "instance_name"
            ],
            "methods": [
              "post",
              "get"
            ]
          },
          "detail": {
            "path": "/v1/instances/{instance_name}/webhooks/{id}/",
            "properties": [
              "instance_name",
              "id"
            ],
            "methods": [
              "put",
              "get",
              "patch",
              "delete"
            ]
          }
        },
        "name": "Webhook",
        "properties": {
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
              }
            ]
          }
        }
      }
   ]  ')
  end
end