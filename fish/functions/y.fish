function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"

    if test -f "$tmp"
        set newdir (cat "$tmp")
        if test -d "$newdir"
            cd "$newdir"
        end
        rm -f "$tmp"
    end
end
