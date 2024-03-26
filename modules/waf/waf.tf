module "waf" {
  source = "./code"
  # enabled     = data.external.check_waf_exists.result.result
  enabled     = var.waf_create
  name_prefix = var.name

  allow_default_action = true

  scope = var.waf_scope

  create_alb_association = true
  alb_arn                = var.alb_arn

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-metric"
    sampled_requests_enabled   = false
  }

  create_logging_configuration = var.enable_logging
  log_destination_configs      = var.log_group
  rules = [

    // WAF AWS Managed Rule 

    {
      name            = "${var.name}-commonruleset"
      priority        = 0
      override_action = "none"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        rule_action_overrides = [
          {
            action_to_use = {
              count = {}
            }

            name = "NoUserAgent_HEADER"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "UserAgent_BadBots_HEADER"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "SizeRestrictions_QUERYSTRING"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "SizeRestrictions_Cookie_HEADER"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "SizeRestrictions_BODY"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "SizeRestrictions_URIPATH"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "EC2MetaDataSSRF_BODY"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "EC2MetaDataSSRF_COOKIE"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "EC2MetaDataSSRF_URIPATH"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "EC2MetaDataSSRF_QUERYARGUMENTS"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "RestrictedExtensions_URIPATH"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "RestrictedExtensions_QUERYARGUMENTS"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "GenericRFI_QUERYARGUMENTS"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "GenericRFI_BODY"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "GenericRFI_URIPATH"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "CrossSiteScripting_COOKIE"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "CrossSiteScripting_QUERYARGUMENTS"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "CrossSiteScripting_BODY"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "CrossSiteScripting_URIPATH"
          },
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-commonruleset-metric"
        sampled_requests_enabled   = false
      }
    },
    {
      name            = "${var.name}-knownbadnnputsruleset",
      priority        = 1
      override_action = "none"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
        rule_action_overrides = [
          {
            action_to_use = {
              count = {}
            }

            name = "Host_localhost_HEADER"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "PROPFIND_METHOD"
          }
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-knownbadnnputsruleset-metric"
        sampled_requests_enabled   = true
      }

    },
    {
      name            = "${var.name}-ipreputationlist",
      priority        = 2
      override_action = "none"

      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
        rule_action_overrides = [
          {
            action_to_use = {
              count = {}
            }

            name = "AWSManagedIPReputationList"
          },
          {
            action_to_use = {
              count = {}
            }

            name = "AWSManagedReconnaissanceList"
          }
        ]
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-ipreputationlist-metric"
        sampled_requests_enabled   = true
      }

    },
    {
      name     = "${var.name}-httpfloodprotection",
      priority = 3
      action   = "count"

      rate_based_statement = {
        limit              = 3000
        aggregate_key_type = "IP"
        scope_down_statement = {
          not_statement = {
            ip_set_reference_statement = {
              arn = var.waf_ip_set_arn
            }
          }
        }
      }


      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-httpfloodprotection-metric"
        sampled_requests_enabled   = true
      }

    },
    # {
    #   name            = "${var.name}-botcontrolruleset",
    #   priority        = 4
    #   override_action = "none"

    #   managed_rule_group_statement = {
    #     name        = "AWSManagedRulesBotControlRuleSet"
    #     vendor_name = "AWS"
    #   }

    #   visibility_config = {
    #     cloudwatch_metrics_enabled = true
    #     metric_name                = "${var.name}-botcontrol-metric"
    #     sampled_requests_enabled   = true
    #   }

    # }

  ]

  tags = {
    Name        = var.name
    Environment = var.env
    System      = var.system
  }
}
