package PoDemo::View::Xslate;
use Moose;
extends 'Catalyst::View::Xslate';

has '+module' => (
    default => sub { [ 'Text::Xslate::Bridge::TT2Like' ] }
);

has '+template_extension' => (
    default => '.tt',
);

has '+syntax' => (
    default => 'TTerse',
);

# po
use I18N::Handle;
has '+function' => (
    default => sub {
        +{
            _ => \&_, #i18n::method
        }
    }
);
my $hl = I18N::Handle->new(
    Gettext => {
        en => PoDemo->config->{en_po_path},
        ja => PoDemo->config->{ja_po_path},
    }
)->accept( qw(en ja) );

$hl->speak( 'ja' );

# 自動判定させたいときはこんな感じ
use I18N::LangTags ();
use I18N::LangTags::Detect;
use I18N::LangTags::List;
override 'process' => sub {
    my ($self, $c) = @_;
        my $languages ||= [
            I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    $c->request->header('Accept-Language')
                )
            ),
            'i-default'
        ];
    my $lang = $languages->[0];
    $lang =~ s/^(.+)-+(.+)/$1/;
    $hl->speak( $lang );
    super();
};

1;

