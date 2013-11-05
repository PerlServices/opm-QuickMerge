# --
# Kernel/Output/HTML/OutputFilterMergeOverview.pm
# Copyright (C) 2013 Perl-Services.de, http://www.perl-services.de/
# --
# $Id: OutputFilterMergeOverview.pm,v 1.1 2011/04/19 10:21:42 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterMergeOverview;

use strict;
use warnings;

use Kernel::System::Encode;
use Kernel::System::Time;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject ConfigObject LogObject LayoutObject ParamObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    if ( $Param{EncodeObject} ) {
        $Self->{EncodeObject} = $Param{EncodeObject};
    }
    else {
        $Self->{EncodeObject} = Kernel::System::Encode->new( %{$Self} );
    }

    if ( $Param{TimeObject} ) {
        $Self->{TimeObject} = $Param{TimeObject};
    }
    else {
        $Self->{TimeObject} = Kernel::System::Time->new( %{$Self} );
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    my @Templates = keys %{ $Param{Templates} || {} };
    @Templates    = map{ "AgentTicketOverview$_" }(qw/Small Medium Preview/) if !@Templates;

    return 1 if !grep{ $Templatename eq $_ }@Templates;

    my $Snippet = qq%
        <li class="AlwaysPresent Bulk" id="QuickMerge">
            <script type="text/javascript">//<![CDATA[
                function quick_merge() {
                    var challenge_token = \$('input[name="ChallengeToken"]').val();
                    var merge_url = 
                        Core.Config.Get('Baselink') +
                        "ChallengeToken=" + challenge_token + 
                        ";Action=AgentTicketBulk;Subaction=Do;MergeToSelection=OptionMergeToOldest";

                    var has_selected = 0;
                    \$('input[name="TicketID"]:checked').each(function(){
                        merge_url += ";TicketID=" + \$(this).val();
                        has_selected++;
                    });

                    if ( has_selected < 2 ) {
                        return false;
                    }

                    \$.ajax({
                        type: 'GET',
                        url: merge_url,
                        success: function(data) {
                            window.location.reload(true);
                        } 
                    });
                }
            //]]>
            </script>
            <a href="#" onclick="quick_merge();" title="\$Text{"Merge with oldest"}">\$Text{"Quick Merge"}</a>
        </li>
    %;

    #scan html output and generate new html input
    ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$1 $Snippet}xmgs;

    return ${ $Param{Data} };
}

1;
