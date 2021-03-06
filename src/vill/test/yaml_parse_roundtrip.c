/* yaml_parse_roundtrip.c */
/* Verify that the yaml_parse() function is accurate by */
/* constructing a yaml file from its returned events, and comparing */
/* that with the original yaml input that was generated by 'viv'. */
#include "../src/yaml_parse.h"  /* yaml_event_type yaml_parse */
#include <assert.h>             /* assert */
#include <stdio.h>              /* fgets popen pclose printf */
#include <stdlib.h>             /* abort */
#include <string.h>             /* strcpy strlen */
#include <unistd.h>             /* getcwd */

// show where to find the 'viv' Perl 6 parser
#define VIV_RELATIVE_PATH ".."

#define USAGE "\nUsage: %s [options] [programfile]\n" \
  " -e cmd  execute cmd instead of programfile (multiple -e possible)\n" \
  " -h      show this help\n" \
  "\n"

const char * temp_filename1 = "/tmp/yaml_parse_roundtrip1.yaml";
const char * temp_filename2 = "/tmp/yaml_parse_roundtrip2.yaml";
#define BUFFER_SIZE 256
char   line_buffer[BUFFER_SIZE];
char * commandline;

int
local_options( int argc, char * argv[] ) {
  int opt;
  commandline = malloc(1);
  strcpy( commandline, "" );
  while ((opt = getopt(argc, argv, "e:h")) != -1) {
    switch (opt) {
      case 'e':
        commandline = (char *) realloc( commandline,
          strlen(commandline) + strlen(optarg) + 1 );
        strcat( commandline, optarg );
        break;
      case 'h':
        fprintf( stderr, USAGE, argv[0] );
        exit(EXIT_SUCCESS);
        break;
      default: /* react to invalid options with help */
        fprintf( stderr, USAGE, argv[0] );
        exit(EXIT_FAILURE);
    }
  }
  return optind;
}

void
yaml_parse_roundtrip( FILE * stream, FILE * outfile ) {
  int need_space = 0;
  enum yaml_event_type event_type;
  while ( (event_type=yaml_parse(stream))!=YAML_EVENT_FILE_END ) {
    switch ( event_type ) {
      case YAML_EVENT_ALIAS:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "*%.*s", (int)yaml_event.len, yaml_event.str );
        break;
      case YAML_EVENT_ANCHOR:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "&%.*s", (int)yaml_event.len, yaml_event.str );
        need_space = 1;
        break;
      case YAML_EVENT_END_FLOW_MAPPING:
        fprintf( outfile, "}" );
        need_space = 0;
        break;
      case YAML_EVENT_END_FLOW_SEQUENCE:
        fprintf( outfile, "]" );
        need_space = 0;
        break;
      case YAML_EVENT_SEQUENCE_ENTRY:
        fprintf( outfile, "\n" );
        fprintf( outfile, "%*s", (yaml_event.map_levels - 1) * 2, "" );
        fprintf( outfile, "-" );
        need_space = 1;
        break;
      case YAML_EVENT_MAPPING_KEY:
        fprintf( outfile, "\n" );
        fprintf( outfile, "%*s", (yaml_event.map_levels - 1) * 2, "" );
        fprintf( outfile, "%.*s:", (int)yaml_event.len, yaml_event.str );
        need_space = 1;
        break;
      case YAML_EVENT_START_FLOW_MAPPING:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "{" );
        need_space = 0;
        break;
      case YAML_EVENT_START_FLOW_SEQUENCE:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "[" );
        need_space = 0;
        break;
      case YAML_EVENT_TAG:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "!%.*s", (int)yaml_event.len, yaml_event.str );
        break;
      case YAML_EVENT_SCALAR_BARE:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "%.*s", (int)yaml_event.len, yaml_event.str );
        break;
      case YAML_EVENT_SCALAR_CONTINUED:
        fprintf( outfile, "\n" );
        fprintf( outfile, "%*s", yaml_event.map_levels * 2, "" );
        fprintf( outfile, "%.*s", (int)yaml_event.len, yaml_event.str );
        need_space = 1;
        break;
      case YAML_EVENT_SCALAR_QUOTED:
        if ( need_space ) {
          fprintf( outfile, " " );
          need_space = 0;
        }
        fprintf( outfile, "'%.*s'", (int)yaml_event.len, yaml_event.str );
        break;
      case YAML_EVENT_DIRECTIVES_END:
        fprintf( outfile, "---" );
        need_space = 1;
        break;
      default:
        fprintf( stderr,  "\nUNKNOWN EVENT %d\n", (int)event_type );
        fprintf( outfile, "\nUNKNOWN EVENT %d\n", (int)event_type );
        abort();
        break;
    }
  }
  fprintf( outfile, "\n" );
}

/* run viv (a Perl 5 program) as a child process and save the output */
int
local_run_viv( char * viv_command, const char * output_filename ) {
  int status;
  char * cwd;
  FILE * infile, * outfile;
  /* stash the current working directory, then chdir to viv's dir */
  cwd = getcwd( NULL, 0);
  assert( cwd != NULL );
  char * stash_current_dir;
  stash_current_dir=(char *)malloc(strlen(cwd)+1);
  assert( stash_current_dir != NULL );
  strcpy( stash_current_dir, cwd );
  assert( chdir( VIV_RELATIVE_PATH ) == 0 );
  /* run viv in its own directory, letting the yaml parser pull lines */
  infile = popen( viv_command, "r" );
  assert( infile != NULL );
  /* stream the viv output to a first temporary file */
  outfile = fopen( output_filename, "w" );
  assert( outfile != NULL );
  while ( fgets(line_buffer, BUFFER_SIZE, infile) != NULL ) {
    fputs( (const char *)line_buffer, outfile );
  }
  fclose( outfile );
  status = pclose( infile );
  assert( chdir( stash_current_dir ) == 0 );
  free( stash_current_dir );
  return status;
}

/* run the diff utility to compare two files */
int
local_run_diff( const char * filename1, const char * filename2 ) {
  int status;
  const char * diff_template = "diff %s %s";
  char * diff_command = (char *) malloc( strlen(diff_template) +
    strlen(filename1) + strlen(filename2) );
  assert( diff_command != NULL );
  sprintf( diff_command, diff_template, filename1, filename2 );
  status = system( diff_command );
  free( diff_command );
  return status;
}

int
local_test_commandline( char * commandline ) {
  int status = 0;
  FILE * infile, * outfile;
  printf( "yaml_parse_roundtrip -e %s%.*s", commandline,
    49 - (int)strlen(commandline),
    "................................................." );
  char * viv_command;
  viv_command = malloc( 12 + strlen(commandline) );
  sprintf( viv_command, "./viv -e '%s'", commandline );
  printf( "%s\n", (status==0) ? "ok" : "not ok" );
  status = local_run_viv( viv_command, temp_filename1 );
  free( viv_command );
  if ( status == 0 ) { /* test more only if viv returned success */
    infile = fopen( temp_filename1, "r" );
    assert( infile != NULL );
    outfile = fopen( temp_filename2,"w");
    assert( outfile != NULL );
    /* convert parse events back to original yaml doc */
    yaml_parse_roundtrip( infile, outfile ); /* TODO: return status */
    fclose( infile );
    fclose( outfile );
    status = local_run_diff( temp_filename1, temp_filename2 );
  }
  return status;
}

/* Generate a YAML file using viv, parse and reconstruct the YAML, */
/* compare the reconstruction with the original. */
int
local_test_one_file( char * programfile ) {
  int status;
  FILE * infile, * outfile;
  printf( "yaml_parse_roundtrip %s%.*s", programfile,
    52 - (int)strlen(programfile),
    "...................................................." );
  char * viv_command;
  viv_command = malloc( 7 + strlen(programfile) );
  sprintf( viv_command, "./viv %s", programfile );
  status = local_run_viv( viv_command, temp_filename1 );
  if ( status == 0 ) { /* test more only if viv returned success */
    infile = fopen( temp_filename1, "r" );
    assert( infile != NULL );
    outfile = fopen( temp_filename2,"w");
    assert( outfile != NULL );
    /* convert parse events back to original yaml doc */
    yaml_parse_roundtrip( infile, outfile ); /* TODO: return status */
    fclose( infile );
    fclose( outfile );
    status = local_run_diff( temp_filename1, temp_filename2 );
  }
  printf( "%s\n", (status==0) ? "ok" : "not ok" );
  return status;
}

/* dispatch tests according to the command line arguments */
int
main( int argc, char *argv[] ) {
  int optind, option, status, pass=0, fail=0;
  optind = local_options( argc, argv );
  if ( strlen(commandline) > 0 ) {
    status = local_test_commandline( commandline );
  }
  else {
    for ( option = optind; option < argc; option++ ) {
      status = local_test_one_file( argv[option] );
      if ( status ) { ++fail; }
      else          { ++pass; }
    }
    if ( argc > 2 ) {
      printf( "totals %d/%d pass %d fail\n", pass, argc - 1, fail );
    }
  }
  return 0;
}
