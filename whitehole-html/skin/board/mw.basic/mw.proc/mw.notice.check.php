<?
/**
 * Bechu-Basic Skin for Gnuboard4
 *
 * Copyright (c) 2008 Choi Jae-Young <www.miwit.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

include_once("_common.php");

header("Content-Type: text/html; charset=$g4[charset]");
$gmnow = gmdate("D, d M Y H:i:s") . " GMT";
header("Expires: 0"); // rfc2616 - Section 14.21
header("Last-Modified: " . $gmnow);
header("Cache-Control: no-store, no-cache, must-revalidate"); // HTTP/1.1
header("Cache-Control: pre-check=0, post-check=0, max-age=0"); // HTTP/1.1
header("Pragma: no-cache"); // HTTP/1.0

// 게시판 관리자 이상 복사, 이동 가능
if ($is_admin != 'board' && $is_admin != 'group' && $is_admin != 'super') 
    exit("게시판 관리자 이상 접근이 가능합니다.");

if ($sw != "up" && $sw != "down")
    alert("sw 값이 제대로 넘어오지 않았습니다.");

if ($sw == 'down') {
    $bo_notice = explode("\n", trim($board[bo_notice]));
    $bo_notice = implode("\n", array_diff($bo_notice, $chk_wr_id));

    sql_query(" update $g4[board_table] set bo_notice = '$bo_notice' where bo_table = '$bo_table' ");

    $msg = "공지를 내렸습니다.";
}
else
{
    $bo_notice = explode("\n", trim($board[bo_notice]));
    $bo_notice = implode("\n", array_unique(array_merge($bo_notice, $chk_wr_id)));

    sql_query(" update $g4[board_table] set bo_notice = '$bo_notice' where bo_table = '$bo_table' ");

    /*$tmp = explode("\n", trim($bo_notice));
    for ($i=0, $m=count($tmp); $i<$m; $i++)
        sql_query(" update $write_table set ca_name = '공지' where wr_id = '{$tmp[$i]}' ");*/

    $msg = "공지로 등록하였습니다.";
}

echo $msg;

?>
