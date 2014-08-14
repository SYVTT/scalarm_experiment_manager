require 'minitest/autorun'
require 'test_helper'
require 'mocha'

require 'gsi/ssh'
require 'gsi/scp'

class GsiSshTest < MiniTest::Test

  def setup
    @proxy = <<-STR
-----BEGIN CERTIFICATE-----
MIIC9TCCAd2gAwIBAgIIZ/5Bpd9t9jMwDQYJKoZIhvcNAQEFBQAwbDELMAkGA1UE
BhMCUEwxEDAOBgNVBAoTB1BMLUdyaWQxEzARBgNVBAoTClV6eXRrb3duaWsxDDAK
BgNVBAoTA0FHSDEUMBIGA1UEAxMLSmFrdWIgTGlwdXQxEjAQBgNVBAMTCXBsZ2ps
aXB1dDAeFw0xNDA2MTQwOTE2MjRaFw0xNDA2MTQyMTE2MjRaMHwxCzAJBgNVBAYT
AlBMMRAwDgYDVQQKEwdQTC1HcmlkMRMwEQYDVQQKEwpVenl0a293bmlrMQwwCgYD
VQQKEwNBR0gxFDASBgNVBAMTC0pha3ViIExpcHV0MRIwEAYDVQQDEwlwbGdqbGlw
dXQxDjAMBgNVBAMTBXByb3h5MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCB
H2a6tNAXYPGiwI4hv0ND5wRk+c7x01l/pxuB/Yulk8vjYiOPmA3gbnwSsfZNy+L+
AE65vPHGOSJZz9SK5olLyDNKvtPkQK9cRKQ3iZGVlE8VclRky2Z9Zj4OQ1jywuPJ
tqINiVa2BlU7vJxNbZ6o72qRDafVtEl557IASnvImwIDAQABow8wDTALBgNVHQ8E
BAMCBLAwDQYJKoZIhvcNAQEFBQADggEBAGTjjVYBwtx3140yu4d9m0oRTYVNnURm
WVKi1GRi/dw/iXEBsC+Ubx+6V1QUPsjG4mrq3pzbdZdSFH8/gSUu8wcNv8juf49s
JgIkAVUM6/PCD6eKG0pmga3o8/570o2/cmJ1etvzqfErXHUiqutnUYdvU7oQpess
7WxorD4isqn3Z1v0mFf2vXbiY9SzxzFWmffWtbbsCEk4ahNOOBuRhYmNOib/5hSR
nFiPmgiZDsS0ZdAbWDw1ulTBF06/Hx7PTx3nhcCe5ye5hgM60QioTjfj6SDJxac4
02G6jIqVJERsSW7NtrBmZ9u5Ol53tXpJyjug4bh5L+E3XbHtBbxGdQk=
-----END CERTIFICATE-----
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAIEfZrq00Bdg8aLA
jiG/Q0PnBGT5zvHTWX+nG4H9i6WTy+NiI4+YDeBufBKx9k3L4v4ATrm88cY5IlnP
1IrmiUvIM0q+0+RAr1xEpDeJkZWUTxVyVGTLZn1mPg5DWPLC48m2og2JVrYGVTu8
nE1tnqjvapENp9W0SXnnsgBKe8ibAgMBAAECgYAOeKd5y2P7CslqFSyYyafPR2ft
rTWtUqOYM/FYS0NIZl0WedxEbqU3fwp2ye0x4OTq1Lv+AxgRwDuCV1GZ06aVZagc
8T+8JJK+PJ/+oQE5mikaGL4OE9ILuPM95lJHz16aoy4BpaUWaJ5KR++tEkhMYSV5
B9L9PJ29axp+0LXw4QJBAP4AYYNNgl0LIrIv7LKuhjEe2eoTNVGKH3dxE5tfk6Eb
9oeZP8TR+0KsQlIwmQw2llqSU9FzujRuE91sqEwakQsCQQCCI3wgxMG52yBBaVbm
FpZlo3MhFSMAtIuObn8Cugm3xrWZu9pcqfONFvnTeJmmMdojS/J2uNzhlmMeLOEZ
yICxAkEApFlQvynW0SdUYuFZkWAVmhDxRWD6XfE2XQ2Ad0dHebZjNOf29/46SrC1
FQM29E0Zyi7mJx9ve19CYUJePyftcwJAZABQif2nv+GaT6lalUQWHdQTzAAp/Yi/
FJvkDXxXq1iOg6vOiBYwiOJ25wFtUEBOl4DsuD4lvVOKps1lzCI+gQJASCgy23z4
g5rC2SAf4q1OsKSZ8osdKUTFLw4RvWvYMkIkWt2lITOHfjrHmQ4u6HcnaRqO4vdV
CCI+kNUj6qNJag==
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIE7TCCAtWgAwIBAgIIZ/5Bpd9t9jMwDQYJKoZIhvcNAQEFBQAwMzELMAkGA1UE
BhMCUEwxEDAOBgNVBAoTB1BMLUdyaWQxEjAQBgNVBAMTCVNpbXBsZSBDQTAeFw0x
MzEwMTAxMzU1NDZaFw0xNDEwMTAxMzU1NDZaMGwxCzAJBgNVBAYTAlBMMRAwDgYD
VQQKEwdQTC1HcmlkMRMwEQYDVQQKEwpVenl0a293bmlrMQwwCgYDVQQKEwNBR0gx
FDASBgNVBAMTC0pha3ViIExpcHV0MRIwEAYDVQQDEwlwbGdqbGlwdXQwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZLZNZqsPmfKXEVyzi/hC4Fkubj6gI
Na6W3k+7KKt8n+yMSvyOuqUMs+KWVHU396AIcoXTEw3jvN7AEt122kKCvDhANOoS
IhlR6U5dh8sv7fZMTaXbY5ra2z4NZhPh8riqi68ilkaRNnz61OXffwtMY6Clhuax
c5M1L4p4Rylxa36Mtu1b2F0Jws/lW5JxLYgmdqeeICXvt5dkz2kPysLno0KPJEoK
pUXtd3JuqC1LgTZ3602jNLcbRQMLSsWcjobqw0IgSO8ZGTjdb3DQn7QdGCIdTD/q
56jZf8DaPumfEZ5ViNCq8NmCzMTkv/tc7pWF5BtAguZCxJbF4Wg/ggsBAgMBAAGj
gcswgcgwHQYDVR0OBBYEFCil96izYpoRuEcbZAgYJohMUmY6MAwGA1UdEwEB/wQC
MAAwHwYDVR0jBBgwFoAUqRNRWWtES3+cofc5zNgB/FRVQC0wGgYDVR0gBBMwETAP
Bg0rBgEEAYKWLQEBAQECMDcGA1UdHwQwMC4wLKAqoCiGJmh0dHA6Ly9wbGdyaWQt
c2NhLndjc3Mud3JvYy5wbC9jcmwuZGVyMA4GA1UdDwEB/wQEAwIEsDATBgNVHSUE
DDAKBggrBgEFBQcDAjANBgkqhkiG9w0BAQUFAAOCAgEAVTOLeEhLNpBaw4x59HJM
9fB3FN7iAF6GYpx3dB4VZniaxOgyjrfamlRpJVVChprE3eobr5luntKiveV3+5VJ
8Xk/qnKV9n9XZLBtMEKj48Rf8UbsluIC1ZPfVPQGSLg4A4j2Ljii1MEO8F6OaI4/
0WVIdpMykiSKTpLKXclPt9Cpuj41S5Yeq/GZf8hn0XIrm+wjYmAvcVV+NXwwYCk8
V0QrSvEziDUMluWXjezpuycW24zk/P9e91FO6wxvq6GhJOrOaKnUC83SPdE3mfD1
y8m+NS4kkw3nai6Xq0+n4VRLFpc3ugdKZaKWZbBv+6hbQNXNV8dhHbmNnFjVEeIz
NC2AH00TqMg93YdcvY8Eydxcg87B60Ivi4FJ1pdK7eUPVimHzAd+b8F6fcMpFeqv
nnGJ/n5wYUfzwtG1I1TqJNL/bVDzVaG+UOki1vojOJcbD2bDAFfBajhFVQCXcgM1
jK+Nw06wNGKQMY7nT8Hf6vnsBf0t2SzJbDUZymo4ksc+0LBGzDNoSdiTimOWTB9Q
+kvtYJOk16eXC9aMyxyb2piXO4mGy1/uScLGNqdw+5etd0jW0HpZDM9cTxXgXykW
m5iWNXgJFMyy+nH85uZ2mFCbFuTMNGIcQU9WIvdQNOVagRISNGQYRwkkSabQ5Uze
59BkmTOlw/m1tj3I439dF00=
-----END CERTIFICATE-----
    STR

    @proxy.strip!
  end

  def test_ssh
    Gsi::SSH.start 'ui.cyfronet.pl', 'plgjliput', @proxy do |ssh|
      # puts ssh.exec! 'echo foo 1>&2'
      # puts ssh.exec! 'echo bar'
      # puts ssh.exec! 'uname -r'
      puts ssh.exec! 'date'
      # ssh.exec! 'echo'
      puts ssh.pop_leftovers.to_s
      puts ssh.pop_leftovers.to_s
    end
  end

  def test_scp
    Gsi::SCP.start 'ui.cyfronet.pl', 'plgjliput', @proxy do |scp|
      scp.upload_multiple! ['/home/kliput/plik1.txt', '/home/kliput/plik2.txt'], '.'
    end
  end

end