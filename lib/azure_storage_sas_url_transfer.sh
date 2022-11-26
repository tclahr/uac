# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
# Transfer file to Azure Storage SAS URL.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file
#   $2: Azure Storage SAS URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
azure_storage_sas_url_transfer()
{
  au_source="${1:-}"
  au_azure_storage_sas_url="${2:-}"

  curl \
    --fail \
    --request PUT \
    --header "x-ms-blob-type: BlockBlob" \
    --header "Content-Type: application/octet-stream" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --upload-file "${au_source}" \
    "${au_azure_storage_sas_url}"

}