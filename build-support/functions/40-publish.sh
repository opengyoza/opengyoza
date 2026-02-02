function publish_release_site {
   # Arguments:
   #   $1 - Path to directory containing all of the release artifacts
   #   $2 - Version (without leading v)
   #
   # Returns:
   #   0 - success
   #   * - failure
   #
   # Notes:
   #   Requires GitHub CLI auth (gh auth login) or GH_TOKEN.
   
   local dist_dir="$1"
   local vers="$2"
   
   if test -z "${dist_dir}"
   then
      err "ERROR: publish_release_site requires a path to release artifacts"
      return 1
   fi
   
   if test -z "${vers}"
   then
      err "ERROR: publish_release_site requires a version"
      return 1
   fi
   
   if ! command -v gh >/dev/null 2>&1
   then
      err "ERROR: gh CLI not found. Install GitHub CLI and authenticate (gh auth login)."
      return 1
   fi
   
   if ! gh auth status -h github.com >/dev/null 2>&1
   then
      err "ERROR: gh CLI is not authenticated. Run 'gh auth login' or set GH_TOKEN."
      return 1
   fi
   
   if ! test -d "${dist_dir}"
   then
      err "ERROR: '${dist_dir}' is not a directory."
      return 1
   fi
   
   local tag="v${vers}"
   if ! gh release view "${tag}" >/dev/null 2>&1
   then
      status "Creating GitHub release ${tag}"
      gh release create "${tag}" --title "OpenGyoza ${vers}" --notes "OpenGyoza ${vers}" || return 1
   fi
   
   local files=()
   while IFS= read -r -d '' file
   do
      files+=("${file}")
   done < <(find "${dist_dir}" -maxdepth 1 -type f -print0)
   
   if test "${#files[@]}" -eq 0
   then
      err "ERROR: No release artifacts found in ${dist_dir}"
      return 1
   fi
   
   status "Uploading release artifacts to GitHub"
   gh release upload "${tag}" "${files[@]}" --clobber || return 1
   
   return 0
}

function confirm_git_remote {
   # Arguments:
   #   $1 - Path to git repo
   #   $2 - remote name
   #
   # Returns:
   #   0 - success
   #   * - error
   #
   
   local remote="$2"
   local url=$(git_remote_url "$1" "${remote}")
   
   echo -e "\n\nConfigured Git Remote: ${remote}"
   echo -e     "Configured Git URL:    ${url}\n"
   
   local answer=""
      
   while true
   do
      case "${answer}" in
         [yY]* )
            status "Remote Accepted"
            return 0
            break
            ;;
         [nN]* )
            err "Remote Rejected"
            return 1
            break
            ;;
         * )
            read -p "Is this Git Remote correct to push ${CONSUL_PKG_NAME} to? [y/n]: " answer
            ;;
      esac
   done
}

function confirm_git_push_changes {
   # Arguments:
   #   $1 - Path to git repo
   #
   # Returns:
   #   0 - success
   #   * - error
   #
   
   if ! test -d "$1"
   then
      err "ERROR: '$1' is not a directory. confirm_git_push_changes must be called with the path to a git repo as the first argument'" 
      return 1
   fi
   
   pushd "${1}" > /dev/null
   
   
   declare -i ret=0
   git_log_summary || ret=1
   if test ${ret} -eq 0
   then
      # put a empty line between the git changes and the prompt
      echo ""
      
      local answer=""
      
      while true
      do
         case "${answer}" in
            [yY]* )
               status "Changes Accepted"
               ret=0
               break
               ;;
            [nN]* )
               err "Changes Rejected"
               ret=1
               break
               ;;
            ?)
               # bindata_assetfs.go will make these meaningless
               git_diff "$(pwd)" ":!agent/bindata_assetfs.go"|| ret 1
               answer=""
               ;;
            * )
               read -p "Are these changes correct? [y/n] (or type ? to show the diff output): " answer
               ;;
         esac
      done
   fi
   
   popd > /dev/null
   return $ret
}

function extract_consul_local {
   # Arguments:
   #   $1 - Path to the zipped binary to test
   #   $2 - Version to look for
   #
   # Returns:
   #   0 - success
   #   * - error
   
   local zfile="${1}/${CONSUL_PKG_NAME}_${2}_$(go env GOOS)_$(go env GOARCH).zip"
   
   if ! test -f "${zfile}"
   then
      err "ERROR: File not found or is not a regular file: ${zfile}"
      return 1
   fi
   
   local ret=0
   local tfile="$(mktemp) -t "${CONSUL_PKG_NAME}_")"

   if unzip -p "${zfile}" "gyoza" > "${tfile}"
   then
      chmod +x "${tfile}"
      echo "${tfile}"
      return 0
   elif unzip -p "${zfile}" "consul" > "${tfile}"
   then
      chmod +x "${tfile}"
      echo "${tfile}"
      return 0
   else
      err "ERROR: Failed to extract gyoza or consul binary from the zip file"
      return 1
   fi
}

function confirm_consul_version {
   # Arguments:
   #   $1 - consul exe to use
   # 
   # Returns:
   #   0 - success
   #   * - error
   local consul_exe="$1"
   
   if ! test -x "${consul_exe}"
   then
      err "ERROR: '${consul_exe} is not an executable"
      return 1
   fi
   
   "${consul_exe}" version
   
   # put a empty line between the version output and the prompt
   echo ""
   
   local answer=""
   
   while true
   do
      case "${answer}" in
         [yY]* )
            status "Version Accepted"
            ret=0
            break
            ;;
         [nN]* )
            err "Version Rejected"
            ret=1
            break
            ;;
         * )
            read -p "Is this ${CONSUL_PKG_NAME} version correct? [y/n]: " answer
            ;;
      esac
   done
}

function confirm_consul_info {
   # Arguments:
   #   $1 - Path to a consul exe that can be run on this system
   #
   # Returns:
   #   0 - success
   #   * - error
   
   local consul_exe="$1"
   local log_file="$(mktemp) -t "${CONSUL_PKG_NAME}_log_")"
   "${consul_exe}" agent -dev > "${log_file}" 2>&1 &
   local consul_pid=$!
   sleep 1
   status "First 25 lines/1s of the agents output:"
   head -n 25 "${log_file}"
   
   echo ""
   local ret=0
   local answer=""
   
   while true
   do
      case "${answer}" in
         [yY]* )
            status "${CONSUL_PKG_NAME} agent output accepted"
            break
            ;;
         [nN]* )
            err "${CONSUL_PKG_NAME} agent output rejected"
            ret=1
            break
            ;;
         * )
            read -p "Is this ${CONSUL_PKG_NAME} agent output correct? [y/n]: " answer
            ;;
      esac
   done
   
   if test "${ret}" -eq 0
   then
      status "${CONSUL_PKG_NAME} info output"
      "${consul_exe}" info
      echo ""
      local answer=""
      
      while true
      do
         case "${answer}" in
            [yY]* )
               status "${CONSUL_PKG_NAME} info output accepted"
               break
               ;;
            [nN]* )
               err "${CONSUL_PKG_NAME} info output rejected"
               return 1
               break
               ;;
            * )
               read -p "Is this ${CONSUL_PKG_NAME} info output correct? [y/n]: " answer
               ;;
         esac
      done
   fi
   
   if test "${ret}" -eq 0
   then
      local tfile="$(mktemp) -t "${CONSUL_PKG_NAME}_")"
      if ! curl -o "${tfile}" "http://localhost:8500/ui/"
      then
         err "ERROR: Failed to curl http://localhost:8500/ui/"
         return 1
      fi
      
      local ui_vers=$(ui_version "${tfile}")
      if test $? -ne 0
      then
         err "ERROR: Failed to determine the ui version from the index.html file"
         return 1
      fi
      status "UI Version: ${ui_vers}"
      local ui_logo_type=$(ui_logo_type "${tfile}")
      if test $? -ne 0
      then
         err "ERROR: Failed to determine the ui logo/binary type from the index.html file"
         return 1
      fi
      status "UI Logo: ${ui_logo_type}"
      
      echo ""
      local answer=""
      
      while true
      do
         case "${answer}" in
            [yY]* )
               status "${CONSUL_PKG_NAME} UI/logo version accepted"
               break
               ;;
            [nN]* )
               err "${CONSUL_PKG_NAME} UI/logo version rejected"
               return 1
               break
               ;;
            * )
               read -p "Is this ${CONSUL_PKG_NAME} UI/logo version correct? [y/n]: " answer
               ;;
         esac
      done
   fi
   

   
   status "Requesting ${CONSUL_PKG_NAME} to leave the cluster / shutdown"
   "${consul_exe}" leave
   wait ${consul_pid} > /dev/null 2>&1
   
   return $?
}

function extract_consul {
   extract_consul_local "$1" "$2"
}

function verify_release_build {
   # Arguments:
   #   $1 - Path to top level Consul source
   #   $2 - expected version (optional - will parse if empty)
   #
   # Returns:
   #   0 - success
   #   * - failure
   
   if ! test -d "$1"
   then
      err "ERROR: '$1' is not a directory. publish_release must be called with the path to the top level source as the first argument'" 
      return 1
   fi
   
   local sdir="$1"
   
   local vers="$(get_version ${sdir} true false)"
   if test -n "$2"
   then
      vers="$2"
   fi
   
   if test -z "${vers}"
   then
      err "Please specify a version (couldn't parse one from the source)." 
      return 1
   fi
   
   status_stage "==> Verifying release files"
   check_release "${sdir}/pkg/dist" "${vers}" true || return 1
   
   status_stage "==> Extracting ${CONSUL_PKG_NAME} version for local system"
   local consul_exe=$(extract_consul "${sdir}/pkg/dist" "${vers}") || return 1
   # make sure to remove the temp file
   trap "rm '${consul_exe}'" EXIT
   
   status_stage "==> Confirming ${CONSUL_PKG_NAME} version"
   confirm_consul_version "${consul_exe}" || return 1
   
   status_stage "==> Confirming ${CONSUL_PKG_NAME} agent info"
   confirm_consul_info "${consul_exe}" || return 1
}

function publish_release {
   # Arguments:
   #   $1 - Path to top level Consul source that contains the built release
   #   $2 - boolean whether to publish to git upstream
   #   $3 - boolean whether to publish to GitHub releases
   #
   # Returns:
   #   0 - success
   #   * - error
   
   if ! test -d "$1"
   then
      err "ERROR: '$1' is not a directory. publish_release must be called with the path to the top level source as the first argument'" 
      return 1
   fi
   
   local sdir="$1"
   local pub_git="$2"
   local pub_release_site="$3"
   
   if test -z "${pub_git}"
   then
      pub_git=1
   fi
   
   if test -z "${pub_release_site}"
   then
      pub_release_site=1
   fi
   
   local vers="$(get_version ${sdir} true false)"
   if test $? -ne 0
   then
      err "Please specify a version (couldn't parse one from the source)." 
      return 1
   fi
   
   verify_release_build "$1" "${vers}" || return 1
   
   status_stage "==> Confirming Git is clean"
   is_git_clean "$1" true || return 1

   status_stage "==> Confirming Git Changes"
   confirm_git_push_changes "$1" || return 1
   
   status_stage "==> Checking for blacklisted Git Remote"
   local remote=$(find_git_remote "${sdir}") || return 1
   git_remote_not_blacklisted "${sdir}" "${remote}" || return 1
   
   status_stage "==> Confirming Git Remote"
   confirm_git_remote "${sdir}" "${remote}" || return 1
   
   if is_set "${pub_git}"
   then
      status_stage "==> Pushing to Git"
      git_push_ref "$1" "" "${remote}" || return 1
      git_push_ref "$1" "v${vers}" "${remote}" || return 1
   fi
   
   if is_set "${pub_release_site}"
   then
      status_stage "==> Publishing to GitHub releases"
      publish_release_site "${sdir}/pkg/dist" "${vers}" || return 1
   fi
   
   return 0
}
