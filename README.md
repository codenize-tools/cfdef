# Cfdef

Repol is a tool to manage CloudFront.

It defines the state of CloudFront using DSL, and updates CloudFront according to DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cfdef'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cfdef

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
cfdef -e -o Cffile  # export CloudFront
vi CFfile
cfdef -a --dry-run
cfdef -a            # apply `CFfile`
```

## Help

```
Usage: cfdef [options]
    -k, --access-key ACCESS_KEY
    -s, --secret-key SECRET_KEY
    -r, --region REGION
        --profile PROFILE
        --credentials-path PATH
    -a, --apply
    -f, --file FILE
        --dry-run
    -e, --export
    -o, --output FILE
        --split
        --target-origin ID_RGX
        --no-color
        --debug
```

## CFfile example

```ruby
require 'other/cffile'

distribution "EXAMPLEID" do
  aliases do
    quantity 0
  end
  origins do
    quantity 2
    items [
      _{
        id "Custom-ehxample.cpm"
        domain_name "example.cpm"
        origin_path ""
        custom_headers do
          quantity 0
        end
        custom_origin_config do
          http_port 80
          https_port 443
          origin_protocol_policy "http-only"
          origin_ssl_protocols do
            quantity 3
            items "TLSv1", "TLSv1.1", "TLSv1.2"
          end
        end
      },
      _{
        id "S3-example"
        domain_name "example.s3.amazonaws.com"
        origin_path ""
        custom_headers do
          quantity 0
        end
        s3_origin_config do
          origin_access_identity ""
        end
      }
    ]
  end
  default_cache_behavior do
    target_origin_id "S3-example"
    forwarded_values do
      query_string false
      cookies do
        forward "none"
      end
      headers do
        quantity 0
      end
    end
    trusted_signers do
      enabled false
      quantity 0
    end
    viewer_protocol_policy "allow-all"
    min_ttl 0
    allowed_methods do
      quantity 2
      items "GET", "HEAD"
      cached_methods do
        quantity 2
        items "GET", "HEAD"
      end
    end
    smooth_streaming false
    default_ttl 86400
    max_ttl 31536000
    compress false
  end
  cache_behaviors do
    quantity 0
  end
  custom_error_responses do
    quantity 0
  end
  comment ""
  price_class "PriceClass_All"
  enabled true
  viewer_certificate do
    cloud_front_default_certificate true
    minimum_protocol_version "SSLv3"
    certificate_source "cloudfront"
  end
  restrictions do
    geo_restriction do
      restriction_type "none"
      quantity 0
    end
  end
  web_acl_id ""
end
```

## Create Distribution

```sh
$ cat CFfile
distribution do # without ID
  ...
end

$ cfdef -a
```

Identify Distribution using Origin IDs if there is no Distribution ID.

## Delete Distribution

```sh
$ cat CFfile
distribution "EXAMPLEID" do
  ...
  enable false
  ...
end

$ cfdef -a
...

$ cat CFfile
# comment out
#distribution "EXAMPLEID" do
#  ...
#end

$ cfdef -a
```

## ToDo

* Support Streaming Distribution
