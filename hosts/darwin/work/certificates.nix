{ ... }:
let
  awsRdsBundle = builtins.fetchurl {
    name = "aws-rds-pki-bundle.pem";
    url = "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem";
    sha256 = "00qcdx082bbs874l8midd6fk6wbs6y1ny71khpph54kfgsn9r92z";
  };
  awsRedshiftBundle = builtins.fetchurl {
    name = "aws-redshift-pki-bundle.pem";
    url =
      "https://s3.amazonaws.com/redshift-downloads/amazon-trust-ca-bundle.crt";
    sha256 = "0l6mbg5jmpl4fy25di71jaxvq09kjs9qh5b0km5x2704p3jainrn";
  };
in { security.pki.certificateFiles = [ awsRdsBundle awsRedshiftBundle ]; }
