<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let posLinks = [];
    onMount(async () => {
        let lang = window.location.pathname.split("/")[1];
        fetch("/api/posLinks/" + lang).then((r) => {return r.json()}).then((d) => {posLinks = _.filter(d.POSLinks, (l) => l != "") })
    })

</script>

<div>
    {#each posLinks as link}
        <h4>{link.split("Category:")[1].replaceAll("_", " ")}</h4>
    {/each}
</div>

<style></style>