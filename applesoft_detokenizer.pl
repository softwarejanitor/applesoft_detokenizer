#!/usr/bin/perl -w

use strict;

my %tokens = (
  128 => "END",
  129 => "FOR",
  130 => "NEXT",
  131 => "DATA",
  132 => "INPUT",
  133 => "DEL",
  134 => "DIM",
  135 => "READ",
  136 => "GR",
  137 => "TEXT",
  138 => "PR#",
  139 => "IN#",
  140 => "CALL",
  141 => "PLOT",
  142 => "HLIN",
  143 => "VLIN",
  144 => "HGR2",
  145 => "HGR",
  146 => "HCOLOR=",
  147 => "HPLOT",
  148 => "DRAW",
  149 => "XDRAW",
  150 => "HTAB",
  151 => "HOME",
  152 => "ROT=",
  153 => "SCALE=",
  154 => "SHLOAD",
  155 => "TRACE",
  156 => "NOTRACE",
  157 => "NORMAL",
  158 => "INVERSE",
  159 => "FLASH",
  160 => "COLOR=",
  161 => "POP",
  162 => "VTAB",
  163 => "HIMEM:",
  164 => "LOMEM:",
  165 => "ONERR",
  166 => "RESUME",
  167 => "RECALL",
  168 => "STORE",
  169 => "SPEED=",
  170 => "LET",
  171 => "GOTO",
  172 => "RUN",
  173 => "IF",
  174 => "RESTORE",
  175 => "&",
  176 => "GOSUB",
  177 => "RETURN",
  178 => "REM",
  179 => "STOP",
  180 => "ON",
  181 => "WAIT",
  182 => "LOAD",
  183 => "SAVE",
  184 => "DEF",
  185 => "POKE",
  186 => "PRINT",
  187 => "CONT",
  188 => "LIST",
  189 => "CLEAR",
  190 => "GET",
  191 => "NEW",
  192 => "TAB",
  193 => "TO",
  194 => "FN",
  195 => "SPC(",
  196 => "THEN",
  197 => "AT",
  198 => "NOT",
  199 => "STEP",
  200 => "+",
  201 => "-",
  202 => "*",
  203 => "/",
  204 => "^",
  205 => "AND",
  206 => "OR",
  207 => ">",
  208 => "=",
  209 => "<",
  210 => "SGN",
  211 => "INT",
  212 => "ABS",
  213 => "USR",
  214 => "FRE",
  215 => "SCRN",
  216 => "PDL",
  217 => "POS",
  218 => "SQR",
  219 => "RND",
  220 => "LOG",
  221 => "EXP",
  222 => "COS",
  223 => "SIN",
  224 => "TAN",
  225 => "ATN",
  226 => "PEEK",
  227 => "LEN",
  228 => "STR\$",
  229 => "VAL",
  230 => "ASC",
  231 => "CHR\$",
  232 => "LEFT\$",
  233 => "RIGHT\$",
  234 => "MID\$",
);

sub detokenize {
  my ($fp) = @_;

  my $prevptr = 0;

  my $skip = getc($fp);
  $skip = getc($fp);

  while (1) {
    my $lo;
    my $hi;
    my $tok;

    $lo = getc($fp);  # Ignore low byte of pointer to next line
    $hi = getc($fp);  # Ignore high byte of pointer to next line

    if (! defined $lo || ! defined $hi) {
      die "Premature EOF\n";
    }
    if (ord($lo) == 0 && ord($hi) == 0) {
      my $tok = getc($fp);
      #if (defined $tok) {
      #  warn sprintf("Extraneous data after 0/0 EOF tokens\n");
      #}
      return;
    }

    my $curptr = ord($lo) + 256 * ord($hi);
    if ($curptr < 2048) {
      die sprintf("Invalid pointer %d\n", $curptr);
    }
    if ($curptr < $prevptr) {
      die sprintf("Line pointer %d < prev %d\n", $curptr, $prevptr);
    }
    $prevptr = $curptr;

    $lo = getc($fp);  # low byte of line number
    $hi = getc($fp);  # high byte of line number

    if (! defined $lo || ! defined $hi) {
      die "Premature EOF\n";
    }

    print sprintf("%d ", ord($lo) + 256 * ord($hi));

    while (defined ($tok = getc($fp))) {
      last if (ord($tok) == 0);

      if (ord($tok) > 127) {
        if (defined $tokens{ord($tok)}) {
          print sprintf(" %s ", $tokens{ord($tok)});
        } else {
          print " ??? ";
        }
      } else {
        print sprintf("%c", ord($tok));
      }
    }

    if (!defined $tok) {
      die "Premature EOF\n";
    }

    print "\n";
  }
}

my $filename = shift or die "Must supply filename\n";

my $fp;

if (open($fp, "<$filename")) {
  detokenize($fp);

  close($fp);
}

1;

